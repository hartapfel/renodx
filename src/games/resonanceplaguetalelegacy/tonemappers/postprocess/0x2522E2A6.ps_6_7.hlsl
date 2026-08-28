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

Texture2D<float4> t9 : register(t9);

Texture2D<float4> t14 : register(t14);

Texture2D<float4> t16 : register(t16);

Texture2D<float4> t17 : register(t17);

#include "../../common.hlsli"

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

SamplerState s1 : register(s1);

SamplerState s2 : register(s2);

SamplerState s3 : register(s3);

SamplerState s4 : register(s4);

SamplerState s5 : register(s5);

SamplerState s7 : register(s7);

SamplerState s9 : register(s9);

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
  float _95 = _58 + _65;
  float _96 = _59 + _66;
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
  float3 renodx_chromatic_aberration_input = ResonanceSelectChromaticAberrationInput(
      float3(_137, _138, _139),
      max(_134.rgb, 0.f.xxx),
      float2(_56, _57),
      t0,
      s0,
      _127);
  _137 = renodx_chromatic_aberration_input.x;
  _138 = renodx_chromatic_aberration_input.y;
  _139 = renodx_chromatic_aberration_input.z;
  int _142 = asint((User_000.UserConstant_Z_000[3].z));
  bool _143 = ((int)_142 > (int)0);
  float _172;
  float _257;
  float _294;
  float _484;
  float _523;
  float _524;
  float _525;
  float _633;
  [branch]
  if (_143) {
    bool _148 = ((PostProcess_000.PostProcessConstant_Z_000[7].x) > 0.0f);
    if (_148) {
      float _150 = _36.x + TEXCOORD.x;
      float _151 = _46 + TEXCOORD.y;
      float4 _154 = t2.SampleLevel(s2, float2(_150, _151), 0.0f);
      bool _158 = ((PostProcess_000.PostProcessConstant_Z_000[6].y) == 1.0f);
      if (_158) {
        float4 _161 = t7.Load(int3(0, 0, 0));
        float _166 = _161.x - (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
        float _167 = (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _166;
        _172 = _167;
      } else {
        _172 = (PostProcess_000.PostProcessConstant_Z_000[5].x);
      }
      float _176 = _154.x - (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
      float _177 = (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _176;
      float _179 = _172 * (PostProcess_000.PostProcessConstant_Z_000[6].w);
      float _180 = _179 + _172;
      float _181 = _172 - _179;
      float _182 = max(_177, _181);
      float _183 = min(_182, _180);
      float _186 = _177 - _183;
      float _187 = (PostProcess_000.PostProcessConstant_Z_000[5].w) * _186;
      float _189 = _183 - (PostProcess_000.PostProcessConstant_Z_000[5].y);
      float _190 = _189 * _177;
      float _191 = _187 / _190;
      float _192 = min(_191, 0.0f);
      float _194 = _179 + 1.0f;
      float _195 = 1.0f / _194;
      float _196 = _192 * (PostProcess_000.PostProcessConstant_Z_000[7].z);
      float _197 = max(0.0f, _191);
      float _200 = (PostProcess_000.PostProcessConstant_Z_000[18].x) * _197;
      float _201 = _200 + _196;
      float _202 = _201 * _195;
      float _203 = max(_202, -1.0f);
      float _204 = min(_203, 1.0f);
      float _205 = max(_204, -0.30000001192092896f);
      float _206 = min(_205, 1.0f);
      float _208 = -0.0f - (PostProcess_000.PostProcessConstant_Z_000[6].x);
      float _209 = _206 * _208;
      float _210 = _150 + -0.5f;
      float _211 = _151 + -0.5f;
      float _212 = _210 * _210;
      float _213 = _211 * _211;
      float _214 = _213 + _212;
      float _215 = sqrt(_214);
      float _216 = log2(_215);
      float _217 = _216 * (PostProcess_000.PostProcessConstant_Z_000[7].y);
      float _218 = exp2(_217);
      float _219 = _218 * (PostProcess_000.PostProcessConstant_Z_000[7].x);
      float _220 = dot(float2(_210, _211), float2(_210, _211));
      float _221 = rsqrt(_220);
      float _222 = _221 * _210;
      float _223 = _221 * _211;
      float _224 = abs(_209);
      float _228 = _219 * _224;
      float _229 = -0.0f - _228;
      float _230 = (User_000.UserConstant_Z_000[2].x) * _222;
      float _231 = _230 * _229;
      float _232 = (User_000.UserConstant_Z_000[2].y) * _223;
      float _233 = _232 * _229;
      float _234 = _224 * _219;
      float _235 = _230 * _234;
      float _236 = _232 * _234;
      float _237 = _235 + _150;
      float _238 = _236 + _151;
      float _239 = _231 + _124;
      float _240 = _233 + _120;
      float _241 = max(_61, _127);
      float4 _242 = t0.SampleLevel(s0, float2(_239, _240), _241);
      float4 _244 = t0.SampleLevel(s0, float2(_237, _238), _241);
      float4 _246 = t2.SampleLevel(s2, float2(_239, _240), 0.0f);
      if (_158) {
        float4 _250 = t7.Load(int3(0, 0, 0));
        float _252 = _250.x - (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
        float _253 = (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _252;
        _257 = _253;
      } else {
        _257 = (PostProcess_000.PostProcessConstant_Z_000[5].x);
      }
      float _258 = _246.x - (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
      float _259 = (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _258;
      float _260 = _257 * (PostProcess_000.PostProcessConstant_Z_000[6].w);
      float _261 = _260 + _257;
      float _262 = _257 - _260;
      float _263 = max(_259, _262);
      float _264 = min(_263, _261);
      float _265 = _259 - _264;
      float _266 = _265 * (PostProcess_000.PostProcessConstant_Z_000[5].w);
      float _267 = _264 - (PostProcess_000.PostProcessConstant_Z_000[5].y);
      float _268 = _267 * _259;
      float _269 = _266 / _268;
      float _270 = min(_269, 0.0f);
      float _271 = _260 + 1.0f;
      float _272 = 1.0f / _271;
      float _273 = _270 * (PostProcess_000.PostProcessConstant_Z_000[7].z);
      float _274 = max(0.0f, _269);
      float _275 = _274 * (PostProcess_000.PostProcessConstant_Z_000[18].x);
      float _276 = _275 + _273;
      float _277 = _276 * _272;
      float _278 = max(_277, -1.0f);
      float _279 = min(_278, 1.0f);
      float _280 = max(_279, -0.30000001192092896f);
      float _281 = min(_280, 1.0f);
      float _282 = _281 * _208;
      float4 _283 = t2.SampleLevel(s2, float2(_237, _238), 0.0f);
      if (_158) {
        float4 _287 = t7.Load(int3(0, 0, 0));
        float _289 = _287.x - (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
        float _290 = (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _289;
        _294 = _290;
      } else {
        _294 = (PostProcess_000.PostProcessConstant_Z_000[5].x);
      }
      float _295 = _283.x - (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
      float _296 = (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _295;
      float _297 = _294 * (PostProcess_000.PostProcessConstant_Z_000[6].w);
      float _298 = _297 + _294;
      float _299 = _294 - _297;
      float _300 = max(_296, _299);
      float _301 = min(_300, _298);
      float _302 = _296 - _301;
      float _303 = _302 * (PostProcess_000.PostProcessConstant_Z_000[5].w);
      float _304 = _301 - (PostProcess_000.PostProcessConstant_Z_000[5].y);
      float _305 = _304 * _296;
      float _306 = _303 / _305;
      float _307 = min(_306, 0.0f);
      float _308 = _297 + 1.0f;
      float _309 = 1.0f / _308;
      float _310 = _307 * (PostProcess_000.PostProcessConstant_Z_000[7].z);
      float _311 = max(0.0f, _306);
      float _312 = _311 * (PostProcess_000.PostProcessConstant_Z_000[18].x);
      float _313 = _312 + _310;
      float _314 = _313 * _309;
      float _315 = max(_314, -1.0f);
      float _316 = min(_315, 1.0f);
      float _317 = max(_316, -0.30000001192092896f);
      float _318 = min(_317, 1.0f);
      float _319 = _318 * _208;
      float _320 = abs(_282);
      float _321 = _320 / (PostProcess_000.PostProcessConstant_Z_000[6].x);
      float _322 = ceil(_321);
      float _323 = saturate(_322);
      float _324 = _242.x - _137;
      float _325 = _323 * _324;
      float _326 = _325 + _137;
      float _327 = abs(_319);
      float _328 = _327 / (PostProcess_000.PostProcessConstant_Z_000[6].x);
      float _329 = ceil(_328);
      float _330 = saturate(_329);
      float _331 = _244.z - _139;
      float _332 = _330 * _331;
      float _333 = _332 + _139;
      _523 = _326;
      _524 = _138;
      _525 = _333;
    } else {
      _523 = _137;
      _524 = _138;
      _525 = _139;
    }
  } else {
    int _336 = asint((User_000.UserConstant_Z_000[3].y));
    bool _337 = ((int)_336 > (int)0);
    if (_337) {
      float _339 = _36.x + TEXCOORD.x;
      float _340 = _46 + TEXCOORD.y;
      float4 _343 = t4.Sample(s4, float2(_339, _340));
      float4 _350 = t5.Sample(s5, float2(_339, _340));
      float _354 = (PostProcess_000.PostProcessConstant_Z_000[6].x) * _350.x;
      float _358 = _354 * (PostProcess_000.PostProcessConstant_Z_000[7].x);
      float _359 = _354 * (PostProcess_000.PostProcessConstant_Z_000[7].y);
      float _360 = _358 + _339;
      float _361 = _359 + _340;
      float4 _362 = t4.Sample(s4, float2(_360, _361));
      float4 _364 = t5.Sample(s5, float2(_360, _361));
      float _366 = _364.x * (PostProcess_000.PostProcessConstant_Z_000[6].x);
      float _367 = abs(_366);
      float _369 = _367 / (PostProcess_000.PostProcessConstant_Z_000[7].w);
      float _370 = _362.z - _343.z;
      float _371 = _369 * _370;
      float _372 = _343.x - _137;
      float _373 = _343.y - _138;
      float _374 = _343.z - _139;
      float _375 = _374 + _371;
      float _376 = _372 * _343.w;
      float _377 = _373 * _343.w;
      float _378 = _375 * _343.w;
      float _379 = _376 + _137;
      float _380 = _377 + _138;
      float _381 = _378 + _139;
      _523 = _379;
      _524 = _380;
      _525 = _381;
    } else {
      int _384 = asint((User_000.UserConstant_Z_000[3].x));
      bool _385 = ((int)_384 > (int)0);
      [branch]
      if (_385) {
        float4 _389 = t7.Sample(s7, float2(TEXCOORD.x, TEXCOORD.y));
        float _391 = abs(_389.x);
        _484 = _391;
      } else {
        float4 _395 = t2.SampleLevel(s2, float2(TEXCOORD.x, TEXCOORD.y), 0.0f);
        float _397 = TEXCOORD.x * 2.0f;
        float _398 = TEXCOORD.y * 2.0f;
        float _399 = _397 + -1.0f;
        float _400 = _398 + -1.0f;
        float _421 = (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][8].x) * _399;
        float _422 = mad(_400, (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][8].y), _421);
        float _423 = mad(_395.x, (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][8].z), _422);
        float _424 = _423 + (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][8].w);
        float _425 = (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][9].x) * _399;
        float _426 = mad(_400, (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][9].y), _425);
        float _427 = mad(_395.x, (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][9].z), _426);
        float _428 = _427 + (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][9].w);
        float _429 = (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][10].x) * _399;
        float _430 = mad(_400, (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][10].y), _429);
        float _431 = mad(_395.x, (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][10].z), _430);
        float _432 = _431 + (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][10].w);
        float _433 = (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][11].x) * _399;
        float _434 = mad(_400, (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][11].y), _433);
        float _435 = mad(_395.x, (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][11].z), _434);
        float _436 = _435 + (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][11].w);
        float _437 = _424 / _436;
        float _438 = _428 / _436;
        float _439 = _432 / _436;
        float _440 = _437 * _437;
        float _441 = _438 * _438;
        float _442 = _441 + _440;
        float _443 = _439 * _439;
        float _444 = _442 + _443;
        float _445 = sqrt(_444);
        float4 _448 = t5.Sample(s5, float2(TEXCOORD.x, TEXCOORD.y));
        float _454 = (PostProcess_000.PostProcessConstant_Z_000[6].w) * (PostProcess_000.PostProcessConstant_Z_000[5].x);
        float _455 = _454 + (PostProcess_000.PostProcessConstant_Z_000[5].x);
        float _456 = (PostProcess_000.PostProcessConstant_Z_000[5].x) - _454;
        float _457 = max(_445, _456);
        float _458 = min(_457, _455);
        float _460 = _445 - _458;
        float _461 = _460 * (PostProcess_000.PostProcessConstant_Z_000[5].w);
        float _463 = _458 - (PostProcess_000.PostProcessConstant_Z_000[5].y);
        float _464 = _463 * _445;
        float _465 = _461 / _464;
        float _466 = min(_465, 0.0f);
        float _469 = _454 + 1.0f;
        float _470 = 1.0f / _469;
        float _471 = (PostProcess_000.PostProcessConstant_Z_000[7].z) * _466;
        float _472 = max(0.0f, _465);
        float _475 = (PostProcess_000.PostProcessConstant_Z_000[18].x) * _472;
        float _476 = _475 + _471;
        float _477 = _476 * _470;
        float _478 = min(_448.x, _477);
        float _479 = abs(_478);
        float _480 = abs(_477);
        float _481 = max(_479, _480);
        float _482 = saturate(_481);
        _484 = _482;
      }
      float _487 = (PostProcess_000.PostProcessConstant_Z_000[6].x) * _484;
      float4 _490 = t4.Sample(s4, float2(TEXCOORD.x, TEXCOORD.y));
      float _497 = (PostProcess_000.PostProcessConstant_Z_000[7].x) * _487;
      float _498 = (PostProcess_000.PostProcessConstant_Z_000[7].y) * _487;
      float _499 = _497 + TEXCOORD.x;
      float _500 = _498 + TEXCOORD.y;
      float4 _501 = t4.Sample(s4, float2(_499, _500));
      float4 _505 = t5.Sample(s5, float2(_499, _500));
      float _507 = abs(_505.x);
      float _508 = _501.z - _490.z;
      float _509 = _507 * _508;
      float _510 = _487 + -1.0f;
      float _511 = saturate(_510);
      float _512 = _490.x - _137;
      float _513 = _490.y - _138;
      float _514 = _490.z - _139;
      float _515 = _514 + _509;
      float _516 = _511 * _512;
      float _517 = _511 * _513;
      float _518 = _515 * _511;
      float _519 = _516 + _137;
      float _520 = _517 + _138;
      float _521 = _518 + _139;
      _523 = _519;
      _524 = _520;
      _525 = _521;
    }
  }
  float4 _529 = t17.Load(int3(0, 0, 0));
  float _538 = (Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[87].y) * 335.718017578125f;
  float _539 = _529.x * _538;
  float _540 = _539 * _523;
  float _541 = _540 * (PostProcess_000.PostProcessConstant_Z_000[14].x);
  float _542 = _539 * _524;
  float _543 = _542 * (PostProcess_000.PostProcessConstant_Z_000[14].y);
  float _544 = _539 * _525;
  float _545 = _544 * (PostProcess_000.PostProcessConstant_Z_000[14].z);
  float _546 = _541 + 1.0f;
  float _547 = _543 + 1.0f;
  float _548 = _545 + 1.0f;
  float _549 = log2(_546);
  float _550 = log2(_547);
  float _551 = log2(_548);
  float _552 = (PostProcess_000.PostProcessConstant_Z_320[0].x) * 0.07434873282909393f;
  float _553 = _552 * _549;
  float _554 = _552 * _550;
  float _555 = _551 * _552;
  float _556 = _553 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _557 = _554 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _558 = _555 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float4 _561 = t3.Sample(s3, float3(_556, _557, _558));
  float _565 = _561.x * 13.450128555297852f;
  float _566 = _561.y * 13.450128555297852f;
  float _567 = _561.z * 13.450128555297852f;
  float _568 = exp2(_565);
  float _569 = exp2(_566);
  float _570 = exp2(_567);
  float _571 = _568 + -1.0f;
  float _572 = _569 + -1.0f;
  float _573 = _570 + -1.0f;
  float _574 = _571 * 0.0029786902014166117f;
  float _575 = _572 * 0.0029786902014166117f;
  float _576 = _573 * 0.0029786902014166117f;
  float3 resonance_scaled_lut_output = ResonanceApplyPostProcessLUT(
      float3(_541 * 0.0029786902014166117f, _543 * 0.0029786902014166117f, _545 * 0.0029786902014166117f),
      float3(_574 * (User_000.UserConstant_Z_000[4].x), _575 * (User_000.UserConstant_Z_000[4].y), _576 * (User_000.UserConstant_Z_000[4].z)),
      User_000.UserConstant_Z_000[4].rgb);
  resonance_scaled_lut_output = ResonanceApplyPerceptualFilmGrain(resonance_scaled_lut_output, SV_Position.xy);
  float _581 = resonance_scaled_lut_output.x;
  float _582 = resonance_scaled_lut_output.y;
  float _583 = resonance_scaled_lut_output.z;
  float _589 = (PostProcess_000.PostProcessConstant_Z_000[10].z) * TEXCOORD.x;
  float _590 = _589 * (PostProcess_000.PostProcessConstant_Z_000[9].x);
  float _591 = (PostProcess_000.PostProcessConstant_Z_000[10].z) * TEXCOORD.y;
  float _592 = _591 * (PostProcess_000.PostProcessConstant_Z_000[9].y);
  float _595 = _590 + (PostProcess_000.PostProcessConstant_Z_000[9].z);
  float _596 = _592 + (PostProcess_000.PostProcessConstant_Z_000[9].w);
  float4 _599 = t9.Sample(s9, float2(_595, _596));
  float _603 = dot(float3(_581, _582, _583), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  bool _606 = ((PostProcess_000.PostProcessConstant_Z_000[10].x) > 0.0f);
  int _609 = asint((Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[1].w));
  int _610 = select(_606, _609, 0);
  float _611 = (PostProcess_000.PostProcessConstant_Z_000[10].z) * SV_Position.x;
  float _612 = (PostProcess_000.PostProcessConstant_Z_000[10].z) * SV_Position.y;
  uint _613 = uint(_611);
  uint _614 = uint(_612);
  int _615 = _613 & 63;
  int _616 = _614 & 63;
  float4 _618 = t6.Load(int4(_615, _616, _610, 0));
  bool _620 = ((PostProcess_000.PostProcessConstant_Z_000[10].z) < 1.0f);
  if (_620) {
    float _622 = _611 * 0.015625f;
    float _623 = _612 * 0.015625f;
    float _624 = float((uint)_609);
    float _625 = select(_606, _624, 0.0f);
    float4 _627 = t6.SampleLevel(s1, float3(_622, _623, _625), 0.0f);
    float _629 = _618.y - _627.y;
    float _630 = _629 * (PostProcess_000.PostProcessConstant_Z_000[10].z);
    float _631 = _630 + _627.y;
    _633 = _631;
  } else {
    _633 = _618.y;
  }
  float _634 = _599.x * -2.0f;
  float _635 = _634 * _633;
  float _636 = _633 * 2.0f;
  float _637 = _636 * _599.y;
  float _638 = _636 * _599.z;
  float _639 = _635 + _599.x;
  float _640 = _637 - _599.y;
  float _641 = _638 - _599.z;
  float _642 = _639 * _599.x;
  float _643 = _640 * _599.y;
  float _644 = _641 * _599.z;
  float _645 = _603 + 1.0f;
  float _646 = _603 / _645;
  float _647 = _646 + -9.999999747378752e-05f;
  float _648 = _647 * 1111.111083984375f;
  float _649 = saturate(_648);
  float _650 = _649 * 2.0f;
  float _651 = 3.0f - _650;
  float _652 = _649 * _649;
  float _653 = _652 * _651;
  bool _655 = ((PostProcess_000.PostProcessConstant_Z_000[10].y) > 0.0f);
  float _656 = float((bool)_655);
  float _657 = dot(float3(_642, _643, _644), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  float _658 = _657 - _642;
  float _659 = _657 - _643;
  float _660 = _657 - _644;
  float _661 = _658 * _656;
  float _662 = _659 * _656;
  float _663 = _660 * _656;
  float _664 = _661 + _642;
  float _665 = _662 + _643;
  float _666 = _663 + _644;
  float _670 = (PostProcess_000.PostProcessConstant_Z_000[2].y) - (PostProcess_000.PostProcessConstant_Z_000[2].x);
  float _671 = _670 * _646;
  float _672 = _671 + (PostProcess_000.PostProcessConstant_Z_000[2].x);
  float _673 = _653 * _672;
  float _674 = _673 * _664;
  float _675 = _673 * _665;
  float _676 = _673 * _666;
  float _677 = _674 + _581;
  float _678 = _675 + _582;
  float _679 = _676 + _583;
  float _680 = max(0.0f, _677);
  float _681 = max(0.0f, _678);
  float _682 = max(0.0f, _679);
  float3 resonance_film_grain_output = ResonanceSelectFilmGrainOutput(
      float3(_680, _681, _682),
      resonance_scaled_lut_output);
  float _697;
  float _709;
  float _721;
  [branch]
  if (!ResonanceIsPsychoV()) {
    _680 = resonance_film_grain_output.x;
    _681 = resonance_film_grain_output.y;
    _682 = resonance_film_grain_output.z;
    float _685 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 2.0f;
    float _686 = log2(_680);
    float _687 = _685 * _686;
    float _688 = exp2(_687);
    float _689 = _688 + -1.0f;
    float _690 = _680 + -1.0f;
    float _691 = _689 / _690;
    bool _692 = !(_680 == 1.0f);
    float _693 = _691 + -1.0f;
    float _694 = _693 / _691;
    float _695 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
    float _696 = _695 / _685;
    _697 = select(_692, _694, _696);
    float _698 = log2(_681);
    float _699 = _698 * _685;
    float _700 = exp2(_699);
    float _701 = _700 + -1.0f;
    float _702 = _681 + -1.0f;
    float _703 = _701 / _702;
    bool _704 = !(_681 == 1.0f);
    float _705 = _703 + -1.0f;
    float _706 = _705 / _703;
    float _707 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
    float _708 = _707 / _685;
    _709 = select(_704, _706, _708);
    float _710 = log2(_682);
    float _711 = _710 * _685;
    float _712 = exp2(_711);
    float _713 = _712 + -1.0f;
    float _714 = _682 + -1.0f;
    float _715 = _713 / _714;
    bool _716 = !(_682 == 1.0f);
    float _717 = _715 + -1.0f;
    float _718 = _717 / _715;
    float _719 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
    float _720 = _719 / _685;
    _721 = select(_716, _718, _720);
  } else {
    _697 = 0.f;
    _709 = 0.f;
    _721 = 0.f;
  }
  float3 resonance_post_process_output = ResonanceApplyPostProcessToneMap(
      resonance_film_grain_output,
      float3(_697, _709, _721),
      true);
  float _722 = resonance_post_process_output.x;
  float _723 = resonance_post_process_output.y;
  float _724 = resonance_post_process_output.z;
  float _725 = log2(_722);
  float _726 = log2(_723);
  float _727 = log2(_724);
  float _728 = _725 * 0.4166666567325592f;
  float _729 = _726 * 0.4166666567325592f;
  float _730 = _727 * 0.4166666567325592f;
  float _731 = exp2(_728);
  float _732 = exp2(_729);
  float _733 = exp2(_730);
  float _734 = _731 * 1.0549999475479126f;
  float _735 = _732 * 1.0549999475479126f;
  float _736 = _733 * 1.0549999475479126f;
  float _737 = _734 + -0.054999999701976776f;
  float _738 = _735 + -0.054999999701976776f;
  float _739 = _736 + -0.054999999701976776f;
  float _740 = _722 * 12.920000076293945f;
  float _741 = _723 * 12.920000076293945f;
  float _742 = _724 * 12.920000076293945f;
  bool _743 = (_722 <= 0.0031308000907301903f);
  bool _744 = (_723 <= 0.0031308000907301903f);
  bool _745 = (_724 <= 0.0031308000907301903f);
  float _746 = select(_743, _740, _737);
  float _747 = select(_744, _741, _738);
  float _748 = select(_745, _742, _739);
  float _749 = log2(_746);
  float _750 = log2(_747);
  float _751 = log2(_748);
  float _752 = floor(_749);
  float _753 = floor(_750);
  float _754 = floor(_751);
  float _755 = _752 + -6.0f;
  float _756 = _753 + -6.0f;
  float _757 = _754 + -5.0f;
  float _758 = exp2(_755);
  float _759 = exp2(_756);
  float _760 = exp2(_757);
  bool _761 = (_746 <= 0.0f);
  bool _762 = (_747 <= 0.0f);
  bool _763 = (_748 <= 0.0f);
  float _764 = select(_761, 0.0f, _758);
  float _765 = select(_762, 0.0f, _759);
  float _766 = select(_763, 0.0f, _760);
  uint _767 = uint(SV_Position.x);
  uint _768 = uint(SV_Position.y);
  int _769 = _767 & 63;
  int _770 = _768 & 63;
  float4 _772 = t1.Load(int4(_769, _770, _609, 0));
  float4 _774 = t6.Load(int4(_769, _770, _609, 0));
  float _777 = _772.x * _764;
  float _778 = _774.x * _765;
  float _779 = _774.y * _766;
  float _780 = _777 + _746;
  float _781 = _778 + _747;
  float _782 = _779 + _748;
  SV_Target.x = _780;
  SV_Target.y = _781;
  SV_Target.z = _782;
  SV_Target.w = _134.w;
  if (ResonanceIsPsychoV()) {
    SV_Target.rgb = ResonanceRenderIntermediatePassDithered(
        resonance_post_process_output, SV_Position.xy);
  }
  return SV_Target;
}