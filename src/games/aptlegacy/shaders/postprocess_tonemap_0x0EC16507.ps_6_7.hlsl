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
  float GlobalCB_Z__GlobalConstant_Z_1696;
  float GlobalCB_Z__GlobalConstant_Z_1700;
  float GlobalCB_Z__GlobalConstant_Z_1704;
  float GlobalCB_Z__GlobalConstant_Z_1708;
  float GlobalCB_Z__GlobalConstant_Z_1712;
  float GlobalCB_Z__GlobalConstant_Z_1716;
  float GlobalCB_Z__GlobalConstant_Z_1720;
  float GlobalCB_Z__GlobalConstant_Z_1724;
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
  GlobalCB_Z__ViewportConstant_Z GlobalCB_Z_1728;
  GlobalCB_Z__AnchorConstant_Z GlobalCB_Z_1824;
  GlobalCB_Z__ViewConstant_Z GlobalCB_Z_2176;
  GlobalCB_Z__ProjConstant_Z GlobalCB_Z_2720;
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

Texture2D<float4> t16 : register(t16);

Texture2D<float4> t17 : register(t17);

#include "../common.hlsli"

cbuffer cb1 : register(b1) {
  GlobalCB_Z Global_000 : packoffset(c000.x);
};

cbuffer cb0 : register(b0) {
  UserConstant_Z User_000 : packoffset(c000.x);
};

cbuffer cb2 : register(b2) {
  PostProcessConstant_Z PostProcess_000 : packoffset(c000.x);
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
  float4 _36 = t14.Sample(s14, float2(TEXCOORD.x, TEXCOORD.y));
  float4 _42 = t16.Sample(s0, float2(TEXCOORD.z, TEXCOORD.w));
  float _45 = _42.y * 0.10000000149011612f;
  float _46 = _45 + _36.y;
  float _47 = _42.y * 0.5f;
  float _48 = _47 + _36.z;
  float _49 = exp2(_48);
  float _50 = _49 + -1.0f;
  float _53 = (PostProcess_000.PostProcessConstant_Z_000[11].y) * _50;
  float _54 = _53 + 1.0f;
  float _55 = log2(_54);
  float _56 = _36.x + TEXCOORD.z;
  float _57 = _46 + TEXCOORD.w;
  float _58 = _36.x + TEXCOORD.x;
  float _59 = _46 + TEXCOORD.y;
  float _60 = _55 + 1.0f;
  float _61 = log2(_60);
  float _65 = 0.5f - (PostProcess_000.PostProcessConstant_Z_000[19].x);
  float _66 = 0.5f - (PostProcess_000.PostProcessConstant_Z_000[19].y);
  float _67 = _65 + _56;
  float _68 = _66 + _57;
  float _69 = _67 * 2.0f;
  float _70 = _68 * 2.0f;
  float _71 = _69 + -1.0f;
  float _72 = _70 + -1.0f;
  float _76 = _72 * (Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[51].y);
  float _77 = abs(_71);
  float _78 = abs(_72);
  float _80 = (PostProcess_000.PostProcessConstant_Z_000[19].z) * 2.0f;
  float _81 = _80 + -1.0f;
  float _82 = _77 - _81;
  float _83 = _78 - _81;
  float _84 = saturate(_82);
  float _85 = saturate(_83);
  float _86 = _84 * (Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[51].x);
  float _87 = _86 * _71;
  float _88 = _76 * _85;
  float _89 = _87 * _87;
  float _90 = _88 * _88;
  float _91 = _89 + _90;
  float _92 = sqrt(_91);
  float _95 = _65 + _58;
  float _96 = _66 + _59;
  float _97 = _95 * 2.0f;
  float _98 = _97 + -1.0f;
  float _99 = _96 * 1.125f;
  float _100 = _99 + -0.5625f;
  float _101 = _98 * _98;
  float _102 = _100 * _100;
  float _103 = _101 + _102;
  float _104 = sqrt(_103);
  float _105 = _104 * 0.8715755343437195f;
  float _106 = _105 * _105;
  float _107 = _106 + -0.15000000596046448f;
  float _108 = _107 * 1.8181819915771484f;
  float _109 = saturate(_108);
  float _110 = _109 * 2.0f;
  float _111 = 3.0f - _110;
  float _112 = (PostProcess_000.PostProcessConstant_Z_000[2].w) * _92;
  float _113 = _109 * _109;
  float _114 = _113 * _112;
  float _115 = _114 * _106;
  float _116 = _115 * _111;
  float _118 = (PostProcess_000.PostProcessConstant_Z_000[2].z) * _87;
  float _119 = (PostProcess_000.PostProcessConstant_Z_000[2].z) * _88;
  float _120 = _119 + _57;
  float _121 = _56 - _118;
  float _122 = _42.x * 0.010840999893844128f;
  float _123 = _56 + _122;
  float _124 = _123 + _118;
  float _125 = _57 + _122;
  float _126 = _125 - _119;
  float _127 = max(_116, _61);
  float4 _130 = t0.SampleLevel(s0, float2(_124, _120), _127);
  float4 _132 = t0.SampleLevel(s0, float2(_121, _126), _127);
  float4 _134 = t0.SampleLevel(s0, float2(_56, _57), _127);
  float _137 = max(_130.x, 0.0f);
  float _138 = max(_132.y, 0.0f);
  float _139 = max(_134.z, 0.0f);
  float4 _141 = t12.SampleLevel(s0, float2(_56, _57), 0.0f);
  float4 _147 = t8.Sample(s8, float2(_58, _59));
  int _153 = asint((User_000.UserConstant_Z_000[3].z));
  bool _154 = ((int)_153 > (int)0);
  float _183;
  float _184;
  float _185;
  float _190;
  float _191;
  float _192;
  float _221;
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
  float _694;
  float _703;
  float _712;
  float _760;
  float _761;
  float _762;
  if (!_154) {
    bool _158 = !((PostProcess_000.PostProcessConstant_Z_000[17].z) >= -1.0f);
    float _162 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _147.x;
    float _163 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _147.y;
    float _164 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _147.z;
    float _165 = _162 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    float _166 = _163 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    float _167 = _164 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    if (!_158) {
      float _169 = _165 * _141.x;
      float _170 = _166 * _141.y;
      float _171 = _167 * _141.z;
      _183 = _169;
      _184 = _170;
      _185 = _171;
    } else {
      float _173 = saturate(_165);
      float _174 = saturate(_166);
      float _175 = saturate(_167);
      float _176 = _141.x - _137;
      float _177 = _141.y - _138;
      float _178 = _141.z - _139;
      float _179 = _173 * _176;
      float _180 = _174 * _177;
      float _181 = _175 * _178;
      _183 = _179;
      _184 = _180;
      _185 = _181;
    }
    float _186 = _183 + _137;
    float _187 = _184 + _138;
    float _188 = _185 + _139;
    _190 = _186;
    _191 = _187;
    _192 = _188;
  } else {
    _190 = _137;
    _191 = _138;
    _192 = _139;
  }
  [branch]
  if (_154) {
    bool _197 = ((PostProcess_000.PostProcessConstant_Z_000[7].x) > 0.0f);
    if (_197) {
      float _199 = _36.x + TEXCOORD.x;
      float _200 = _46 + TEXCOORD.y;
      float4 _203 = t2.SampleLevel(s2, float2(_199, _200), 0.0f);
      bool _207 = ((PostProcess_000.PostProcessConstant_Z_000[6].y) == 1.0f);
      if (_207) {
        float4 _210 = t7.Load(int3(0, 0, 0));
        float _215 = _210.x - (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
        float _216 = (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _215;
        _221 = _216;
      } else {
        _221 = (PostProcess_000.PostProcessConstant_Z_000[5].x);
      }
      float _225 = _203.x - (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
      float _226 = (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _225;
      float _228 = _221 * (PostProcess_000.PostProcessConstant_Z_000[6].w);
      float _229 = _228 + _221;
      float _230 = _221 - _228;
      float _231 = max(_226, _230);
      float _232 = min(_231, _229);
      float _235 = _226 - _232;
      float _236 = (PostProcess_000.PostProcessConstant_Z_000[5].w) * _235;
      float _238 = _232 - (PostProcess_000.PostProcessConstant_Z_000[5].y);
      float _239 = _238 * _226;
      float _240 = _236 / _239;
      float _241 = min(_240, 0.0f);
      float _243 = _228 + 1.0f;
      float _244 = 1.0f / _243;
      float _245 = _241 * (PostProcess_000.PostProcessConstant_Z_000[7].z);
      float _246 = max(0.0f, _240);
      float _249 = (PostProcess_000.PostProcessConstant_Z_000[18].x) * _246;
      float _250 = _249 + _245;
      float _251 = _250 * _244;
      float _252 = max(_251, -1.0f);
      float _253 = min(_252, 1.0f);
      float _254 = max(_253, -0.30000001192092896f);
      float _255 = min(_254, 1.0f);
      float _257 = -0.0f - (PostProcess_000.PostProcessConstant_Z_000[6].x);
      float _258 = _255 * _257;
      float _259 = _199 + -0.5f;
      float _260 = _200 + -0.5f;
      float _261 = _259 * _259;
      float _262 = _260 * _260;
      float _263 = _262 + _261;
      float _264 = sqrt(_263);
      float _265 = log2(_264);
      float _266 = _265 * (PostProcess_000.PostProcessConstant_Z_000[7].y);
      float _267 = exp2(_266);
      float _268 = _267 * (PostProcess_000.PostProcessConstant_Z_000[7].x);
      float _269 = dot(float2(_259, _260), float2(_259, _260));
      float _270 = rsqrt(_269);
      float _271 = _270 * _259;
      float _272 = _270 * _260;
      float _273 = abs(_258);
      float _277 = _268 * _273;
      float _278 = -0.0f - _277;
      float _279 = (User_000.UserConstant_Z_000[2].x) * _271;
      float _280 = _279 * _278;
      float _281 = (User_000.UserConstant_Z_000[2].y) * _272;
      float _282 = _281 * _278;
      float _283 = _273 * _268;
      float _284 = _279 * _283;
      float _285 = _281 * _283;
      float _286 = _284 + _199;
      float _287 = _285 + _200;
      float _288 = _280 + _124;
      float _289 = _282 + _120;
      float _290 = max(_61, _127);
      float4 _291 = t0.SampleLevel(s0, float2(_288, _289), _290);
      float4 _293 = t0.SampleLevel(s0, float2(_286, _287), _290);
      float4 _295 = t2.SampleLevel(s2, float2(_288, _289), 0.0f);
      if (_207) {
        float4 _299 = t7.Load(int3(0, 0, 0));
        float _301 = _299.x - (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
        float _302 = (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _301;
        _306 = _302;
      } else {
        _306 = (PostProcess_000.PostProcessConstant_Z_000[5].x);
      }
      float _307 = _295.x - (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
      float _308 = (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _307;
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
      float _331 = _330 * _257;
      float4 _332 = t2.SampleLevel(s2, float2(_286, _287), 0.0f);
      if (_207) {
        float4 _336 = t7.Load(int3(0, 0, 0));
        float _338 = _336.x - (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
        float _339 = (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _338;
        _343 = _339;
      } else {
        _343 = (PostProcess_000.PostProcessConstant_Z_000[5].x);
      }
      float _344 = _332.x - (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
      float _345 = (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _344;
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
      float _368 = _367 * _257;
      float _369 = abs(_331);
      float _370 = _369 / (PostProcess_000.PostProcessConstant_Z_000[6].x);
      float _371 = ceil(_370);
      float _372 = saturate(_371);
      float _373 = _291.x - _190;
      float _374 = _372 * _373;
      float _375 = _374 + _190;
      float _376 = abs(_368);
      float _377 = _376 / (PostProcess_000.PostProcessConstant_Z_000[6].x);
      float _378 = ceil(_377);
      float _379 = saturate(_378);
      float _380 = _293.z - _192;
      float _381 = _379 * _380;
      float _382 = _381 + _192;
      _572 = _375;
      _573 = _191;
      _574 = _382;
    } else {
      _572 = _190;
      _573 = _191;
      _574 = _192;
    }
  } else {
    int _385 = asint((User_000.UserConstant_Z_000[3].y));
    bool _386 = ((int)_385 > (int)0);
    if (_386) {
      float _388 = _36.x + TEXCOORD.x;
      float _389 = _46 + TEXCOORD.y;
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
      float _421 = _392.x - _190;
      float _422 = _392.y - _191;
      float _423 = _392.z - _192;
      float _424 = _423 + _420;
      float _425 = _421 * _392.w;
      float _426 = _422 * _392.w;
      float _427 = _424 * _392.w;
      float _428 = _425 + _190;
      float _429 = _426 + _191;
      float _430 = _427 + _192;
      _572 = _428;
      _573 = _429;
      _574 = _430;
    } else {
      int _433 = asint((User_000.UserConstant_Z_000[3].x));
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
        float _470 = (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][8].x) * _448;
        float _471 = mad(_449, (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][8].y), _470);
        float _472 = mad(_444.x, (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][8].z), _471);
        float _473 = _472 + (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][8].w);
        float _474 = (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][9].x) * _448;
        float _475 = mad(_449, (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][9].y), _474);
        float _476 = mad(_444.x, (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][9].z), _475);
        float _477 = _476 + (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][9].w);
        float _478 = (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][10].x) * _448;
        float _479 = mad(_449, (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][10].y), _478);
        float _480 = mad(_444.x, (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][10].z), _479);
        float _481 = _480 + (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][10].w);
        float _482 = (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][11].x) * _448;
        float _483 = mad(_449, (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][11].y), _482);
        float _484 = mad(_444.x, (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][11].z), _483);
        float _485 = _484 + (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][11].w);
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
      float _561 = _539.x - _190;
      float _562 = _539.y - _191;
      float _563 = _539.z - _192;
      float _564 = _563 + _558;
      float _565 = _560 * _561;
      float _566 = _560 * _562;
      float _567 = _564 * _560;
      float _568 = _565 + _190;
      float _569 = _566 + _191;
      float _570 = _567 + _192;
      _572 = _568;
      _573 = _569;
      _574 = _570;
    }
  }
  if (_154) {
    bool _578 = !((PostProcess_000.PostProcessConstant_Z_000[17].z) >= -1.0f);
    float _582 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _147.x;
    float _583 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _147.y;
    float _584 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _147.z;
    float _585 = _582 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    float _586 = _583 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    float _587 = _584 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    if (!_578) {
      float _589 = _585 * _141.x;
      float _590 = _586 * _141.y;
      float _591 = _587 * _141.z;
      _603 = _589;
      _604 = _590;
      _605 = _591;
    } else {
      float _593 = saturate(_585);
      float _594 = saturate(_586);
      float _595 = saturate(_587);
      float _596 = _141.x - _572;
      float _597 = _141.y - _573;
      float _598 = _141.z - _574;
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
  float _625 = (Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[87].y) * 335.718017578125f;
  float _626 = _616.x * _625;
  float _627 = _626 * _610;
  float _628 = _627 * (PostProcess_000.PostProcessConstant_Z_000[14].x);
  float _629 = _626 * _611;
  float _630 = _629 * (PostProcess_000.PostProcessConstant_Z_000[14].y);
  float _631 = _626 * _612;
  float _632 = _631 * (PostProcess_000.PostProcessConstant_Z_000[14].z);
  float _633 = _628 + 1.0f;
  float _634 = _630 + 1.0f;
  float _635 = _632 + 1.0f;
  float _636 = log2(_633);
  float _637 = log2(_634);
  float _638 = log2(_635);
  float _639 = (PostProcess_000.PostProcessConstant_Z_320[0].x) * 0.07434873282909393f;
  float _640 = _639 * _636;
  float _641 = _639 * _637;
  float _642 = _638 * _639;
  float _643 = _640 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _644 = _641 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _645 = _642 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float4 _648 = t3.Sample(s3, float3(_643, _644, _645));
  float _652 = _648.x * 13.450128555297852f;
  float _653 = _648.y * 13.450128555297852f;
  float _654 = _648.z * 13.450128555297852f;
  float _655 = exp2(_652);
  float _656 = exp2(_653);
  float _657 = exp2(_654);
  float _658 = _655 + -1.0f;
  float _659 = _656 + -1.0f;
  float _660 = _657 + -1.0f;
  float _661 = _658 * 0.0029786902014166117f;
  float _662 = _659 * 0.0029786902014166117f;
  float _663 = _660 * 0.0029786902014166117f;
  float3 apt_scaled_lut_output = APTApplyPostProcessLUTScaling(
      float3(_628 * 0.0029786902014166117f, _630 * 0.0029786902014166117f, _632 * 0.0029786902014166117f),
      float3(_661 * (User_000.UserConstant_Z_000[4].x), _662 * (User_000.UserConstant_Z_000[4].y), _663 * (User_000.UserConstant_Z_000[4].z)),
      t3,
      s3,
      PostProcess_000.PostProcessConstant_Z_320[0].x,
      PostProcess_000.PostProcessConstant_Z_320[0].y,
      User_000.UserConstant_Z_000[4].rgb);
  float _668 = apt_scaled_lut_output.x;
  float _669 = apt_scaled_lut_output.y;
  float _670 = apt_scaled_lut_output.z;
  bool _673 = !((PostProcess_000.PostProcessConstant_Z_000[17].x) == 0.0f);
  if (_673) {
    float _683 = (PostProcess_000.PostProcessConstant_Z_000[10].w) * _668;
    float _684 = (PostProcess_000.PostProcessConstant_Z_000[10].w) * _669;
    float _685 = (PostProcess_000.PostProcessConstant_Z_000[10].w) * _670;
    bool _686 = (_683 < (PostProcess_000.PostProcessConstant_Z_000[16].z));
    if (_686) {
      float _688 = _683 / (PostProcess_000.PostProcessConstant_Z_000[16].z);
      float _689 = 1.0f - _688;
      float _690 = _689 * _689;
      float _691 = _690 * (PostProcess_000.PostProcessConstant_Z_000[15].w);
      float _692 = _691 + _683;
      _694 = _692;
    } else {
      _694 = _683;
    }
    bool _695 = (_684 < (PostProcess_000.PostProcessConstant_Z_000[16].z));
    if (_695) {
      float _697 = _684 / (PostProcess_000.PostProcessConstant_Z_000[16].z);
      float _698 = 1.0f - _697;
      float _699 = _698 * _698;
      float _700 = _699 * (PostProcess_000.PostProcessConstant_Z_000[15].w);
      float _701 = _700 + _684;
      _703 = _701;
    } else {
      _703 = _684;
    }
    bool _704 = (_685 < (PostProcess_000.PostProcessConstant_Z_000[16].z));
    if (_704) {
      float _706 = _685 / (PostProcess_000.PostProcessConstant_Z_000[16].z);
      float _707 = 1.0f - _706;
      float _708 = _707 * _707;
      float _709 = _708 * (PostProcess_000.PostProcessConstant_Z_000[15].w);
      float _710 = _709 + _685;
      _712 = _710;
    } else {
      _712 = _685;
    }
    float _713 = _694 / (PostProcess_000.PostProcessConstant_Z_000[16].x);
    float _714 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 2.0f;
    float _715 = log2(_713);
    float _716 = _715 * _714;
    float _717 = exp2(_716);
    float _718 = _717 + -1.0f;
    float _719 = _713 + -1.0f;
    float _720 = _718 / _719;
    bool _721 = !(_713 == 1.0f);
    float _722 = _720 + -1.0f;
    float _723 = _722 / _720;
    float _724 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
    float _725 = _724 / _714;
    float _726 = select(_721, _723, _725);
    float _727 = _726 * (PostProcess_000.PostProcessConstant_Z_000[16].x);
    float _728 = _703 / (PostProcess_000.PostProcessConstant_Z_000[16].x);
    float _729 = log2(_728);
    float _730 = _729 * _714;
    float _731 = exp2(_730);
    float _732 = _731 + -1.0f;
    float _733 = _728 + -1.0f;
    float _734 = _732 / _733;
    bool _735 = !(_728 == 1.0f);
    float _736 = _734 + -1.0f;
    float _737 = _736 / _734;
    float _738 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
    float _739 = _738 / _714;
    float _740 = select(_735, _737, _739);
    float _741 = _740 * (PostProcess_000.PostProcessConstant_Z_000[16].x);
    float _742 = _712 / (PostProcess_000.PostProcessConstant_Z_000[16].x);
    float _743 = log2(_742);
    float _744 = _743 * _714;
    float _745 = exp2(_744);
    float _746 = _745 + -1.0f;
    float _747 = _742 + -1.0f;
    float _748 = _746 / _747;
    bool _749 = !(_742 == 1.0f);
    float _750 = _748 + -1.0f;
    float _751 = _750 / _748;
    float _752 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
    float _753 = _752 / _714;
    float _754 = select(_749, _751, _753);
    float _755 = _754 * (PostProcess_000.PostProcessConstant_Z_000[16].x);
    float _756 = _727 / (PostProcess_000.PostProcessConstant_Z_000[10].w);
    float _757 = _741 / (PostProcess_000.PostProcessConstant_Z_000[10].w);
    float _758 = _755 / (PostProcess_000.PostProcessConstant_Z_000[10].w);
    _760 = _756;
    _761 = _757;
    _762 = _758;
  } else {
    _760 = _668;
    _761 = _669;
    _762 = _670;
  }
  float3 apt_post_process_output = APTApplyPostProcessToneMap(
      float3(_668, _669, _670),
      float3(_760, _761, _762),
      false);
  _760 = apt_post_process_output.x;
  _761 = apt_post_process_output.y;
  _762 = apt_post_process_output.z;
  float _763 = log2(_760);
  float _764 = log2(_761);
  float _765 = log2(_762);
  float _766 = _763 * 0.4166666567325592f;
  float _767 = _764 * 0.4166666567325592f;
  float _768 = _765 * 0.4166666567325592f;
  float _769 = exp2(_766);
  float _770 = exp2(_767);
  float _771 = exp2(_768);
  float _772 = _769 * 1.0549999475479126f;
  float _773 = _770 * 1.0549999475479126f;
  float _774 = _771 * 1.0549999475479126f;
  float _775 = _772 + -0.054999999701976776f;
  float _776 = _773 + -0.054999999701976776f;
  float _777 = _774 + -0.054999999701976776f;
  float _778 = _760 * 12.920000076293945f;
  float _779 = _761 * 12.920000076293945f;
  float _780 = _762 * 12.920000076293945f;
  bool _781 = (_760 <= 0.0031308000907301903f);
  bool _782 = (_761 <= 0.0031308000907301903f);
  bool _783 = (_762 <= 0.0031308000907301903f);
  float _784 = select(_781, _778, _775);
  float _785 = select(_782, _779, _776);
  float _786 = select(_783, _780, _777);
  float _787 = log2(_784);
  float _788 = log2(_785);
  float _789 = log2(_786);
  float _790 = floor(_787);
  float _791 = floor(_788);
  float _792 = floor(_789);
  float _793 = _790 + -6.0f;
  float _794 = _791 + -6.0f;
  float _795 = _792 + -5.0f;
  float _796 = exp2(_793);
  float _797 = exp2(_794);
  float _798 = exp2(_795);
  bool _799 = (_784 <= 0.0f);
  bool _800 = (_785 <= 0.0f);
  bool _801 = (_786 <= 0.0f);
  float _802 = select(_799, 0.0f, _796);
  float _803 = select(_800, 0.0f, _797);
  float _804 = select(_801, 0.0f, _798);
  int _807 = asint((Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[1].w));
  uint _808 = uint(SV_Position.x);
  uint _809 = uint(SV_Position.y);
  int _810 = _808 & 63;
  int _811 = _809 & 63;
  float4 _813 = t1.Load(int4(_810, _811, _807, 0));
  float4 _816 = t6.Load(int4(_810, _811, _807, 0));
  float _819 = _813.x * _802;
  float _820 = _816.x * _803;
  float _821 = _816.y * _804;
  float _822 = _819 + _784;
  float _823 = _820 + _785;
  float _824 = _821 + _786;
  SV_Target.x = _822;
  SV_Target.y = _823;
  SV_Target.z = _824;
  SV_Target.w = _134.w;
  return SV_Target;
}
