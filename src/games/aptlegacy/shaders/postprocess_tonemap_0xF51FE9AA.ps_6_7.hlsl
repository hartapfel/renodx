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
  float3 renodx_chromatic_aberration_input = APTSelectChromaticAberrationInput(
      float3(_137, _138, _139),
      max(_134.rgb, 0.f.xxx),
      float2(_56, _57),
      t0,
      s0,
      _127);
  _137 = renodx_chromatic_aberration_input.x;
  _138 = renodx_chromatic_aberration_input.y;
  _139 = renodx_chromatic_aberration_input.z;
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
  float _700;
  float _709;
  float _718;
  float _766;
  float _767;
  float _768;
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
      _578 = _375;
      _579 = _191;
      _580 = _382;
    } else {
      _578 = _190;
      _579 = _191;
      _580 = _192;
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
      _578 = _428;
      _579 = _429;
      _580 = _430;
    } else {
      int _433 = asint((User_000.UserConstant_Z_000[3].x));
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
        float4 _499 = t7.Load(int3(0, 0, 0));
        float _504 = _499.x - (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
        float _505 = (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _504;
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
      float _567 = _545.x - _190;
      float _568 = _545.y - _191;
      float _569 = _545.z - _192;
      float _570 = _569 + _564;
      float _571 = _566 * _567;
      float _572 = _566 * _568;
      float _573 = _570 * _566;
      float _574 = _571 + _190;
      float _575 = _572 + _191;
      float _576 = _573 + _192;
      _578 = _574;
      _579 = _575;
      _580 = _576;
    }
  }
  if (_154) {
    bool _584 = !((PostProcess_000.PostProcessConstant_Z_000[17].z) >= -1.0f);
    float _588 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _147.x;
    float _589 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _147.y;
    float _590 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _147.z;
    float _591 = _588 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    float _592 = _589 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    float _593 = _590 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    if (!_584) {
      float _595 = _591 * _141.x;
      float _596 = _592 * _141.y;
      float _597 = _593 * _141.z;
      _609 = _595;
      _610 = _596;
      _611 = _597;
    } else {
      float _599 = saturate(_591);
      float _600 = saturate(_592);
      float _601 = saturate(_593);
      float _602 = _141.x - _578;
      float _603 = _141.y - _579;
      float _604 = _141.z - _580;
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
  float _631 = (Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[87].y) * 335.718017578125f;
  float _632 = _622.x * _631;
  float _633 = _632 * _616;
  float _634 = _633 * (PostProcess_000.PostProcessConstant_Z_000[14].x);
  float _635 = _632 * _617;
  float _636 = _635 * (PostProcess_000.PostProcessConstant_Z_000[14].y);
  float _637 = _632 * _618;
  float _638 = _637 * (PostProcess_000.PostProcessConstant_Z_000[14].z);
  float _639 = _634 + 1.0f;
  float _640 = _636 + 1.0f;
  float _641 = _638 + 1.0f;
  float _642 = log2(_639);
  float _643 = log2(_640);
  float _644 = log2(_641);
  float _645 = (PostProcess_000.PostProcessConstant_Z_320[0].x) * 0.07434873282909393f;
  float _646 = _645 * _642;
  float _647 = _645 * _643;
  float _648 = _644 * _645;
  float _649 = _646 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _650 = _647 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _651 = _648 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float4 _654 = t3.Sample(s3, float3(_649, _650, _651));
  float _658 = _654.x * 13.450128555297852f;
  float _659 = _654.y * 13.450128555297852f;
  float _660 = _654.z * 13.450128555297852f;
  float _661 = exp2(_658);
  float _662 = exp2(_659);
  float _663 = exp2(_660);
  float _664 = _661 + -1.0f;
  float _665 = _662 + -1.0f;
  float _666 = _663 + -1.0f;
  float _667 = _664 * 0.0029786902014166117f;
  float _668 = _665 * 0.0029786902014166117f;
  float _669 = _666 * 0.0029786902014166117f;
  float3 apt_scaled_lut_output = APTApplyPostProcessLUT(
      float3(_634 * 0.0029786902014166117f, _636 * 0.0029786902014166117f, _638 * 0.0029786902014166117f),
      float3(_667 * (User_000.UserConstant_Z_000[4].x), _668 * (User_000.UserConstant_Z_000[4].y), _669 * (User_000.UserConstant_Z_000[4].z)),
      User_000.UserConstant_Z_000[4].rgb);
  apt_scaled_lut_output = APTApplyPerceptualFilmGrain(apt_scaled_lut_output, SV_Position.xy);
  float _674 = apt_scaled_lut_output.x;
  float _675 = apt_scaled_lut_output.y;
  float _676 = apt_scaled_lut_output.z;
  bool _679 = !((PostProcess_000.PostProcessConstant_Z_000[17].x) == 0.0f) && !APTIsPsychoV();
  if (_679) {
    float _689 = (PostProcess_000.PostProcessConstant_Z_000[10].w) * _674;
    float _690 = (PostProcess_000.PostProcessConstant_Z_000[10].w) * _675;
    float _691 = (PostProcess_000.PostProcessConstant_Z_000[10].w) * _676;
    bool _692 = (_689 < (PostProcess_000.PostProcessConstant_Z_000[16].z));
    if (_692) {
      float _694 = _689 / (PostProcess_000.PostProcessConstant_Z_000[16].z);
      float _695 = 1.0f - _694;
      float _696 = _695 * _695;
      float _697 = _696 * (PostProcess_000.PostProcessConstant_Z_000[15].w);
      float _698 = _697 + _689;
      _700 = _698;
    } else {
      _700 = _689;
    }
    bool _701 = (_690 < (PostProcess_000.PostProcessConstant_Z_000[16].z));
    if (_701) {
      float _703 = _690 / (PostProcess_000.PostProcessConstant_Z_000[16].z);
      float _704 = 1.0f - _703;
      float _705 = _704 * _704;
      float _706 = _705 * (PostProcess_000.PostProcessConstant_Z_000[15].w);
      float _707 = _706 + _690;
      _709 = _707;
    } else {
      _709 = _690;
    }
    bool _710 = (_691 < (PostProcess_000.PostProcessConstant_Z_000[16].z));
    if (_710) {
      float _712 = _691 / (PostProcess_000.PostProcessConstant_Z_000[16].z);
      float _713 = 1.0f - _712;
      float _714 = _713 * _713;
      float _715 = _714 * (PostProcess_000.PostProcessConstant_Z_000[15].w);
      float _716 = _715 + _691;
      _718 = _716;
    } else {
      _718 = _691;
    }
    float _719 = _700 / (PostProcess_000.PostProcessConstant_Z_000[16].x);
    float _720 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 2.0f;
    float _721 = log2(_719);
    float _722 = _721 * _720;
    float _723 = exp2(_722);
    float _724 = _723 + -1.0f;
    float _725 = _719 + -1.0f;
    float _726 = _724 / _725;
    bool _727 = !(_719 == 1.0f);
    float _728 = _726 + -1.0f;
    float _729 = _728 / _726;
    float _730 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
    float _731 = _730 / _720;
    float _732 = select(_727, _729, _731);
    float _733 = _732 * (PostProcess_000.PostProcessConstant_Z_000[16].x);
    float _734 = _709 / (PostProcess_000.PostProcessConstant_Z_000[16].x);
    float _735 = log2(_734);
    float _736 = _735 * _720;
    float _737 = exp2(_736);
    float _738 = _737 + -1.0f;
    float _739 = _734 + -1.0f;
    float _740 = _738 / _739;
    bool _741 = !(_734 == 1.0f);
    float _742 = _740 + -1.0f;
    float _743 = _742 / _740;
    float _744 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
    float _745 = _744 / _720;
    float _746 = select(_741, _743, _745);
    float _747 = _746 * (PostProcess_000.PostProcessConstant_Z_000[16].x);
    float _748 = _718 / (PostProcess_000.PostProcessConstant_Z_000[16].x);
    float _749 = log2(_748);
    float _750 = _749 * _720;
    float _751 = exp2(_750);
    float _752 = _751 + -1.0f;
    float _753 = _748 + -1.0f;
    float _754 = _752 / _753;
    bool _755 = !(_748 == 1.0f);
    float _756 = _754 + -1.0f;
    float _757 = _756 / _754;
    float _758 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
    float _759 = _758 / _720;
    float _760 = select(_755, _757, _759);
    float _761 = _760 * (PostProcess_000.PostProcessConstant_Z_000[16].x);
    float _762 = _733 / (PostProcess_000.PostProcessConstant_Z_000[10].w);
    float _763 = _747 / (PostProcess_000.PostProcessConstant_Z_000[10].w);
    float _764 = _761 / (PostProcess_000.PostProcessConstant_Z_000[10].w);
    _766 = _762;
    _767 = _763;
    _768 = _764;
  } else {
    _766 = _674;
    _767 = _675;
    _768 = _676;
  }
  float3 apt_post_process_output = APTApplyPostProcessToneMap(
      float3(_674, _675, _676),
      float3(_766, _767, _768),
      false);
  _766 = apt_post_process_output.x;
  _767 = apt_post_process_output.y;
  _768 = apt_post_process_output.z;
  float _769 = log2(_766);
  float _770 = log2(_767);
  float _771 = log2(_768);
  float _772 = _769 * 0.4166666567325592f;
  float _773 = _770 * 0.4166666567325592f;
  float _774 = _771 * 0.4166666567325592f;
  float _775 = exp2(_772);
  float _776 = exp2(_773);
  float _777 = exp2(_774);
  float _778 = _775 * 1.0549999475479126f;
  float _779 = _776 * 1.0549999475479126f;
  float _780 = _777 * 1.0549999475479126f;
  float _781 = _778 + -0.054999999701976776f;
  float _782 = _779 + -0.054999999701976776f;
  float _783 = _780 + -0.054999999701976776f;
  float _784 = _766 * 12.920000076293945f;
  float _785 = _767 * 12.920000076293945f;
  float _786 = _768 * 12.920000076293945f;
  bool _787 = (_766 <= 0.0031308000907301903f);
  bool _788 = (_767 <= 0.0031308000907301903f);
  bool _789 = (_768 <= 0.0031308000907301903f);
  float _790 = select(_787, _784, _781);
  float _791 = select(_788, _785, _782);
  float _792 = select(_789, _786, _783);
  float _793 = log2(_790);
  float _794 = log2(_791);
  float _795 = log2(_792);
  float _796 = floor(_793);
  float _797 = floor(_794);
  float _798 = floor(_795);
  float _799 = _796 + -6.0f;
  float _800 = _797 + -6.0f;
  float _801 = _798 + -5.0f;
  float _802 = exp2(_799);
  float _803 = exp2(_800);
  float _804 = exp2(_801);
  bool _805 = (_790 <= 0.0f);
  bool _806 = (_791 <= 0.0f);
  bool _807 = (_792 <= 0.0f);
  float _808 = select(_805, 0.0f, _802);
  float _809 = select(_806, 0.0f, _803);
  float _810 = select(_807, 0.0f, _804);
  int _813 = asint((Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[1].w));
  uint _814 = uint(SV_Position.x);
  uint _815 = uint(SV_Position.y);
  int _816 = _814 & 63;
  int _817 = _815 & 63;
  float4 _819 = t1.Load(int4(_816, _817, _813, 0));
  float4 _822 = t6.Load(int4(_816, _817, _813, 0));
  float _825 = _819.x * _808;
  float _826 = _822.x * _809;
  float _827 = _822.y * _810;
  float _828 = _825 + _790;
  float _829 = _826 + _791;
  float _830 = _827 + _792;
  SV_Target.x = _828;
  SV_Target.y = _829;
  SV_Target.z = _830;
  SV_Target.w = _134.w;
  return SV_Target;
}
