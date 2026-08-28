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

Texture2DArray<float4> t6 : register(t6);

Texture2D<float4> t0 : register(t0);

Texture2D<float4> t2 : register(t2);

Texture3D<float4> t3 : register(t3);

Texture2D<float4> t4 : register(t4);

Texture2D<float4> t5 : register(t5);

Texture2D<float4> t7 : register(t7);

Texture2D<float4> t9 : register(t9);

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
  float _94 = _59 + _64;
  float _95 = _60 + _65;
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
  int _143 = asint((User_000.UserConstant_Z_000[7].z));
  bool _144 = ((int)_143 > (int)0);
  float _173;
  float _257;
  float _294;
  float _484;
  float _523;
  float _524;
  float _525;
  float _725;
  float _829;
  float _933;
  float _936;
  float _937;
  float _938;
  float _949;
  float _1074;
  float _1075;
  float _1076;
  float _1123;
  float _1124;
  float _1125;
  float _1139;
  float _1140;
  float _1141;
  float _1197;
  [branch]
  if (_144) {
    bool _149 = ((PostProcess_000.PostProcessConstant_Z_000[7].x) > 0.0f);
    if (_149) {
      float _151 = _37.x + TEXCOORD.x;
      float _152 = _47 + TEXCOORD.y;
      float4 _155 = t2.SampleLevel(s2, float2(_151, _152), 0.0f);
      bool _159 = ((PostProcess_000.PostProcessConstant_Z_000[6].y) == 1.0f);
      if (_159) {
        float4 _162 = t7.Load(int3(0, 0, 0));
        float _167 = _162.x - (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
        float _168 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _167;
        _173 = _168;
      } else {
        _173 = (PostProcess_000.PostProcessConstant_Z_000[5].x);
      }
      float _177 = _155.x - (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
      float _178 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _177;
      float _180 = _173 * (PostProcess_000.PostProcessConstant_Z_000[6].w);
      float _181 = _180 + _173;
      float _182 = _173 - _180;
      float _183 = max(_178, _182);
      float _184 = min(_183, _181);
      float _187 = _178 - _184;
      float _188 = (PostProcess_000.PostProcessConstant_Z_000[5].w) * _187;
      float _190 = _184 - (PostProcess_000.PostProcessConstant_Z_000[5].y);
      float _191 = _190 * _178;
      float _192 = _188 / _191;
      float _193 = min(_192, 0.0f);
      float _195 = _180 + 1.0f;
      float _196 = 1.0f / _195;
      float _197 = _193 * (PostProcess_000.PostProcessConstant_Z_000[7].z);
      float _198 = max(0.0f, _192);
      float _201 = (PostProcess_000.PostProcessConstant_Z_000[18].x) * _198;
      float _202 = _201 + _197;
      float _203 = _202 * _196;
      float _204 = max(_203, -1.0f);
      float _205 = min(_204, 1.0f);
      float _206 = max(_205, -0.30000001192092896f);
      float _207 = min(_206, 1.0f);
      float _209 = -0.0f - (PostProcess_000.PostProcessConstant_Z_000[6].x);
      float _210 = _207 * _209;
      float _211 = _151 + -0.5f;
      float _212 = _152 + -0.5f;
      float _213 = _211 * _211;
      float _214 = _212 * _212;
      float _215 = _214 + _213;
      float _216 = sqrt(_215);
      float _217 = log2(_216);
      float _218 = _217 * (PostProcess_000.PostProcessConstant_Z_000[7].y);
      float _219 = exp2(_218);
      float _220 = _219 * (PostProcess_000.PostProcessConstant_Z_000[7].x);
      float _221 = dot(float2(_211, _212), float2(_211, _212));
      float _222 = rsqrt(_221);
      float _223 = _222 * _211;
      float _224 = _222 * _212;
      float _225 = abs(_210);
      float _229 = _220 * _225;
      float _230 = -0.0f - _229;
      float _231 = (User_000.UserConstant_Z_000[2].x) * _223;
      float _232 = _231 * _230;
      float _233 = (User_000.UserConstant_Z_000[2].y) * _224;
      float _234 = _233 * _230;
      float _235 = _225 * _220;
      float _236 = _231 * _235;
      float _237 = _233 * _235;
      float _238 = _236 + _151;
      float _239 = _237 + _152;
      float _240 = _232 + _123;
      float _241 = _234 + _119;
      float4 _242 = t0.SampleLevel(s0, float2(_240, _241), _128);
      float4 _244 = t0.SampleLevel(s0, float2(_238, _239), _128);
      float4 _246 = t2.SampleLevel(s2, float2(_240, _241), 0.0f);
      if (_159) {
        float4 _250 = t7.Load(int3(0, 0, 0));
        float _252 = _250.x - (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
        float _253 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _252;
        _257 = _253;
      } else {
        _257 = (PostProcess_000.PostProcessConstant_Z_000[5].x);
      }
      float _258 = _246.x - (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
      float _259 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _258;
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
      float _282 = _281 * _209;
      float4 _283 = t2.SampleLevel(s2, float2(_238, _239), 0.0f);
      if (_159) {
        float4 _287 = t7.Load(int3(0, 0, 0));
        float _289 = _287.x - (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
        float _290 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _289;
        _294 = _290;
      } else {
        _294 = (PostProcess_000.PostProcessConstant_Z_000[5].x);
      }
      float _295 = _283.x - (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
      float _296 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _295;
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
      float _319 = _318 * _209;
      float _320 = abs(_282);
      float _321 = _320 / (PostProcess_000.PostProcessConstant_Z_000[6].x);
      float _322 = ceil(_321);
      float _323 = saturate(_322);
      float _324 = _242.x - _138;
      float _325 = _323 * _324;
      float _326 = _325 + _138;
      float _327 = abs(_319);
      float _328 = _327 / (PostProcess_000.PostProcessConstant_Z_000[6].x);
      float _329 = ceil(_328);
      float _330 = saturate(_329);
      float _331 = _244.z - _140;
      float _332 = _330 * _331;
      float _333 = _332 + _140;
      _523 = _326;
      _524 = _139;
      _525 = _333;
    } else {
      _523 = _138;
      _524 = _139;
      _525 = _140;
    }
  } else {
    int _336 = asint((User_000.UserConstant_Z_000[7].y));
    bool _337 = ((int)_336 > (int)0);
    if (_337) {
      float _339 = _37.x + TEXCOORD.x;
      float _340 = _47 + TEXCOORD.y;
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
      float _372 = _343.x - _138;
      float _373 = _343.y - _139;
      float _374 = _343.z - _140;
      float _375 = _374 + _371;
      float _376 = _372 * _343.w;
      float _377 = _373 * _343.w;
      float _378 = _375 * _343.w;
      float _379 = _376 + _138;
      float _380 = _377 + _139;
      float _381 = _378 + _140;
      _523 = _379;
      _524 = _380;
      _525 = _381;
    } else {
      int _384 = asint((User_000.UserConstant_Z_000[7].x));
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
        float _421 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][8].x) * _399;
        float _422 = mad(_400, (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][8].y), _421);
        float _423 = mad(_395.x, (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][8].z), _422);
        float _424 = _423 + (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][8].w);
        float _425 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][9].x) * _399;
        float _426 = mad(_400, (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][9].y), _425);
        float _427 = mad(_395.x, (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][9].z), _426);
        float _428 = _427 + (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][9].w);
        float _429 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][10].x) * _399;
        float _430 = mad(_400, (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][10].y), _429);
        float _431 = mad(_395.x, (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][10].z), _430);
        float _432 = _431 + (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][10].w);
        float _433 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][11].x) * _399;
        float _434 = mad(_400, (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][11].y), _433);
        float _435 = mad(_395.x, (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][11].z), _434);
        float _436 = _435 + (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][11].w);
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
      float _512 = _490.x - _138;
      float _513 = _490.y - _139;
      float _514 = _490.z - _140;
      float _515 = _514 + _509;
      float _516 = _511 * _512;
      float _517 = _511 * _513;
      float _518 = _515 * _511;
      float _519 = _516 + _138;
      float _520 = _517 + _139;
      float _521 = _518 + _140;
      _523 = _519;
      _524 = _520;
      _525 = _521;
    }
  }
  float4 _529 = t17.Load(int3(0, 0, 0));
  float _537 = (PostProcess_000.PostProcessConstant_Z_000[10].w) * 9.999999747378752e-05f;
  float _538 = (Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[87].y) * 11190.6005859375f;
  float _539 = _529.x * _538;
  float _540 = _539 * _523;
  float _541 = _540 * (PostProcess_000.PostProcessConstant_Z_000[14].x);
  float _542 = _541 * _537;
  float _543 = _539 * _524;
  float _544 = _543 * (PostProcess_000.PostProcessConstant_Z_000[14].y);
  float _545 = _544 * _537;
  float _546 = _539 * _525;
  float _547 = _546 * (PostProcess_000.PostProcessConstant_Z_000[14].z);
  float _548 = _547 * _537;
  float _549 = _542 + 1.0f;
  float _550 = _545 + 1.0f;
  float _551 = _548 + 1.0f;
  float _552 = log2(_549);
  float _553 = log2(_550);
  float _554 = log2(_551);
  float _557 = (PostProcess_000.PostProcessConstant_Z_320[0].x) * 0.07434873282909393f;
  float _558 = _557 * _552;
  float _559 = _557 * _553;
  float _560 = _557 * _554;
  float _562 = _558 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _563 = _559 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _564 = _560 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float4 _567 = t3.Sample(s3, float3(_562, _563, _564));
  float _573 = _567.x * 13.450128555297852f;
  float _574 = _567.y * 13.450128555297852f;
  float _575 = _567.z * 13.450128555297852f;
  float _576 = exp2(_573);
  float _577 = exp2(_574);
  float _578 = exp2(_575);
  float _579 = _576 + -1.0f;
  float _580 = _577 + -1.0f;
  float _581 = _578 + -1.0f;
  float _582 = 0.8936070799827576f / (PostProcess_000.PostProcessConstant_Z_000[10].w);
  float _583 = _582 * _579;
  float _584 = _582 * _580;
  float _585 = _582 * _581;
  float3 resonance_scaled_lut_output = ResonanceApplyPostProcessLUT(
      float3(_542 * _582, _545 * _582, _548 * _582),
      float3(_583, _584, _585),
      1.f.xxx);
  _583 = resonance_scaled_lut_output.x;
  _584 = resonance_scaled_lut_output.y;
  _585 = resonance_scaled_lut_output.z;
  bool _588 = ((User_000.UserConstant_Z_000[3].x) > 0.0f) && !ResonanceIsPsychoV();
  if (_588) {
    float _590 = (PostProcess_000.PostProcessConstant_Z_000[10].w) * 1.1190600395202637f;
    float _591 = _583 * _590;
    float _592 = _584 * _590;
    float _593 = _585 * _590;
    float _594 = _591 + 1.0f;
    float _595 = _592 + 1.0f;
    float _596 = _593 + 1.0f;
    float _597 = log2(_594);
    float _598 = log2(_595);
    float _599 = log2(_596);
    float _600 = _597 * 0.07434873282909393f;
    float _601 = _598 * 0.07434873282909393f;
    float _602 = _599 * 0.07434873282909393f;
    int _604 = asint((User_000.UserConstant_Z_000[3].y));
    int _605 = _604 & 1;
    bool _606 = (_605 == 0);
    if (!_606) {
      bool _623 = !(_600 <= (User_000.UserConstant_Z_000[4].x));
      if (!_623) {
        float _625 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _626 = _600 / _625;
        float _627 = _626 * (User_000.UserConstant_Z_000[4].y);
        float _628 = _626 * _626;
        float _629 = _628 * _626;
        float _630 = _629 - _626;
        float _631 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _632 = _625 * _625;
        float _633 = _632 * _631;
        float _634 = _633 * _630;
        float _635 = _634 + _627;
        _725 = _635;
      } else {
        bool _637 = !(_600 <= (User_000.UserConstant_Z_000[4].z));
        if (!_637) {
          float _639 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _640 = max(9.999999974752427e-07f, _639);
          float _641 = _600 - (User_000.UserConstant_Z_000[4].x);
          float _642 = _641 / _640;
          float _643 = 1.0f - _642;
          float _644 = _643 * (User_000.UserConstant_Z_000[4].y);
          float _645 = _642 * (User_000.UserConstant_Z_000[4].w);
          float _646 = _644 + _645;
          float _647 = _643 * _643;
          float _648 = _647 * _643;
          float _649 = _648 - _643;
          float _650 = _649 * (User_000.UserConstant_Z_000[10].x);
          float _651 = _642 * _642;
          float _652 = _651 * _642;
          float _653 = _652 - _642;
          float _654 = _653 * (User_000.UserConstant_Z_000[10].y);
          float _655 = _650 + _654;
          float _656 = _640 * _640;
          float _657 = _656 * 0.1666666716337204f;
          float _658 = _657 * _655;
          float _659 = _646 + _658;
          _725 = _659;
        } else {
          bool _661 = !(_600 <= (User_000.UserConstant_Z_000[9].x));
          if (!_661) {
            float _663 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _664 = max(9.999999974752427e-07f, _663);
            float _665 = _600 - (User_000.UserConstant_Z_000[4].z);
            float _666 = _665 / _664;
            float _667 = 1.0f - _666;
            float _668 = _667 * (User_000.UserConstant_Z_000[4].w);
            float _669 = _666 * (User_000.UserConstant_Z_000[9].y);
            float _670 = _668 + _669;
            float _671 = _667 * _667;
            float _672 = _671 * _667;
            float _673 = _672 - _667;
            float _674 = _673 * (User_000.UserConstant_Z_000[10].y);
            float _675 = _666 * _666;
            float _676 = _675 * _666;
            float _677 = _676 - _666;
            float _678 = _677 * (User_000.UserConstant_Z_000[10].z);
            float _679 = _674 + _678;
            float _680 = _664 * _664;
            float _681 = _680 * 0.1666666716337204f;
            float _682 = _681 * _679;
            float _683 = _670 + _682;
            _725 = _683;
          } else {
            bool _685 = !(_600 <= (User_000.UserConstant_Z_000[9].z));
            if (!_685) {
              float _687 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _688 = max(9.999999974752427e-07f, _687);
              float _689 = _600 - (User_000.UserConstant_Z_000[9].x);
              float _690 = _689 / _688;
              float _691 = 1.0f - _690;
              float _692 = _691 * (User_000.UserConstant_Z_000[9].y);
              float _693 = _690 * (User_000.UserConstant_Z_000[9].w);
              float _694 = _692 + _693;
              float _695 = _691 * _691;
              float _696 = _695 * _691;
              float _697 = _696 - _691;
              float _698 = _697 * (User_000.UserConstant_Z_000[10].z);
              float _699 = _690 * _690;
              float _700 = _699 * _690;
              float _701 = _700 - _690;
              float _702 = _701 * (User_000.UserConstant_Z_000[10].w);
              float _703 = _698 + _702;
              float _704 = _688 * _688;
              float _705 = _704 * 0.1666666716337204f;
              float _706 = _705 * _703;
              float _707 = _694 + _706;
              _725 = _707;
            } else {
              float _709 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _710 = _600 - (User_000.UserConstant_Z_000[9].z);
              float _711 = max(9.999999974752427e-07f, _709);
              float _712 = _710 / _711;
              float _713 = 1.0f - _712;
              float _714 = _713 * (User_000.UserConstant_Z_000[9].w);
              float _715 = _714 + _712;
              float _716 = _713 * _713;
              float _717 = _716 * _713;
              float _718 = _717 - _713;
              float _719 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _720 = _709 * _709;
              float _721 = _720 * _719;
              float _722 = _721 * _718;
              float _723 = _715 + _722;
              _725 = _723;
            }
          }
        }
      }
      float _726 = saturate(_725);
      bool _727 = !(_601 <= (User_000.UserConstant_Z_000[4].x));
      if (!_727) {
        float _729 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _730 = _601 / _729;
        float _731 = _730 * (User_000.UserConstant_Z_000[4].y);
        float _732 = _730 * _730;
        float _733 = _732 * _730;
        float _734 = _733 - _730;
        float _735 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _736 = _729 * _729;
        float _737 = _736 * _735;
        float _738 = _737 * _734;
        float _739 = _738 + _731;
        _829 = _739;
      } else {
        bool _741 = !(_601 <= (User_000.UserConstant_Z_000[4].z));
        if (!_741) {
          float _743 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _744 = max(9.999999974752427e-07f, _743);
          float _745 = _601 - (User_000.UserConstant_Z_000[4].x);
          float _746 = _745 / _744;
          float _747 = 1.0f - _746;
          float _748 = _747 * (User_000.UserConstant_Z_000[4].y);
          float _749 = _746 * (User_000.UserConstant_Z_000[4].w);
          float _750 = _748 + _749;
          float _751 = _747 * _747;
          float _752 = _751 * _747;
          float _753 = _752 - _747;
          float _754 = _753 * (User_000.UserConstant_Z_000[10].x);
          float _755 = _746 * _746;
          float _756 = _755 * _746;
          float _757 = _756 - _746;
          float _758 = _757 * (User_000.UserConstant_Z_000[10].y);
          float _759 = _754 + _758;
          float _760 = _744 * _744;
          float _761 = _760 * 0.1666666716337204f;
          float _762 = _761 * _759;
          float _763 = _750 + _762;
          _829 = _763;
        } else {
          bool _765 = !(_601 <= (User_000.UserConstant_Z_000[9].x));
          if (!_765) {
            float _767 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _768 = max(9.999999974752427e-07f, _767);
            float _769 = _601 - (User_000.UserConstant_Z_000[4].z);
            float _770 = _769 / _768;
            float _771 = 1.0f - _770;
            float _772 = _771 * (User_000.UserConstant_Z_000[4].w);
            float _773 = _770 * (User_000.UserConstant_Z_000[9].y);
            float _774 = _772 + _773;
            float _775 = _771 * _771;
            float _776 = _775 * _771;
            float _777 = _776 - _771;
            float _778 = _777 * (User_000.UserConstant_Z_000[10].y);
            float _779 = _770 * _770;
            float _780 = _779 * _770;
            float _781 = _780 - _770;
            float _782 = _781 * (User_000.UserConstant_Z_000[10].z);
            float _783 = _778 + _782;
            float _784 = _768 * _768;
            float _785 = _784 * 0.1666666716337204f;
            float _786 = _785 * _783;
            float _787 = _774 + _786;
            _829 = _787;
          } else {
            bool _789 = !(_601 <= (User_000.UserConstant_Z_000[9].z));
            if (!_789) {
              float _791 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _792 = max(9.999999974752427e-07f, _791);
              float _793 = _601 - (User_000.UserConstant_Z_000[9].x);
              float _794 = _793 / _792;
              float _795 = 1.0f - _794;
              float _796 = _795 * (User_000.UserConstant_Z_000[9].y);
              float _797 = _794 * (User_000.UserConstant_Z_000[9].w);
              float _798 = _796 + _797;
              float _799 = _795 * _795;
              float _800 = _799 * _795;
              float _801 = _800 - _795;
              float _802 = _801 * (User_000.UserConstant_Z_000[10].z);
              float _803 = _794 * _794;
              float _804 = _803 * _794;
              float _805 = _804 - _794;
              float _806 = _805 * (User_000.UserConstant_Z_000[10].w);
              float _807 = _802 + _806;
              float _808 = _792 * _792;
              float _809 = _808 * 0.1666666716337204f;
              float _810 = _809 * _807;
              float _811 = _798 + _810;
              _829 = _811;
            } else {
              float _813 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _814 = _601 - (User_000.UserConstant_Z_000[9].z);
              float _815 = max(9.999999974752427e-07f, _813);
              float _816 = _814 / _815;
              float _817 = 1.0f - _816;
              float _818 = _817 * (User_000.UserConstant_Z_000[9].w);
              float _819 = _818 + _816;
              float _820 = _817 * _817;
              float _821 = _820 * _817;
              float _822 = _821 - _817;
              float _823 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _824 = _813 * _813;
              float _825 = _824 * _823;
              float _826 = _825 * _822;
              float _827 = _819 + _826;
              _829 = _827;
            }
          }
        }
      }
      float _830 = saturate(_829);
      bool _831 = !(_602 <= (User_000.UserConstant_Z_000[4].x));
      if (!_831) {
        float _833 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _834 = _602 / _833;
        float _835 = _834 * (User_000.UserConstant_Z_000[4].y);
        float _836 = _834 * _834;
        float _837 = _836 * _834;
        float _838 = _837 - _834;
        float _839 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _840 = _833 * _833;
        float _841 = _840 * _839;
        float _842 = _841 * _838;
        float _843 = _842 + _835;
        _933 = _843;
      } else {
        bool _845 = !(_602 <= (User_000.UserConstant_Z_000[4].z));
        if (!_845) {
          float _847 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _848 = max(9.999999974752427e-07f, _847);
          float _849 = _602 - (User_000.UserConstant_Z_000[4].x);
          float _850 = _849 / _848;
          float _851 = 1.0f - _850;
          float _852 = _851 * (User_000.UserConstant_Z_000[4].y);
          float _853 = _850 * (User_000.UserConstant_Z_000[4].w);
          float _854 = _852 + _853;
          float _855 = _851 * _851;
          float _856 = _855 * _851;
          float _857 = _856 - _851;
          float _858 = _857 * (User_000.UserConstant_Z_000[10].x);
          float _859 = _850 * _850;
          float _860 = _859 * _850;
          float _861 = _860 - _850;
          float _862 = _861 * (User_000.UserConstant_Z_000[10].y);
          float _863 = _858 + _862;
          float _864 = _848 * _848;
          float _865 = _864 * 0.1666666716337204f;
          float _866 = _865 * _863;
          float _867 = _854 + _866;
          _933 = _867;
        } else {
          bool _869 = !(_602 <= (User_000.UserConstant_Z_000[9].x));
          if (!_869) {
            float _871 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _872 = max(9.999999974752427e-07f, _871);
            float _873 = _602 - (User_000.UserConstant_Z_000[4].z);
            float _874 = _873 / _872;
            float _875 = 1.0f - _874;
            float _876 = _875 * (User_000.UserConstant_Z_000[4].w);
            float _877 = _874 * (User_000.UserConstant_Z_000[9].y);
            float _878 = _876 + _877;
            float _879 = _875 * _875;
            float _880 = _879 * _875;
            float _881 = _880 - _875;
            float _882 = _881 * (User_000.UserConstant_Z_000[10].y);
            float _883 = _874 * _874;
            float _884 = _883 * _874;
            float _885 = _884 - _874;
            float _886 = _885 * (User_000.UserConstant_Z_000[10].z);
            float _887 = _882 + _886;
            float _888 = _872 * _872;
            float _889 = _888 * 0.1666666716337204f;
            float _890 = _889 * _887;
            float _891 = _878 + _890;
            _933 = _891;
          } else {
            bool _893 = !(_602 <= (User_000.UserConstant_Z_000[9].z));
            if (!_893) {
              float _895 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _896 = max(9.999999974752427e-07f, _895);
              float _897 = _602 - (User_000.UserConstant_Z_000[9].x);
              float _898 = _897 / _896;
              float _899 = 1.0f - _898;
              float _900 = _899 * (User_000.UserConstant_Z_000[9].y);
              float _901 = _898 * (User_000.UserConstant_Z_000[9].w);
              float _902 = _900 + _901;
              float _903 = _899 * _899;
              float _904 = _903 * _899;
              float _905 = _904 - _899;
              float _906 = _905 * (User_000.UserConstant_Z_000[10].z);
              float _907 = _898 * _898;
              float _908 = _907 * _898;
              float _909 = _908 - _898;
              float _910 = _909 * (User_000.UserConstant_Z_000[10].w);
              float _911 = _906 + _910;
              float _912 = _896 * _896;
              float _913 = _912 * 0.1666666716337204f;
              float _914 = _913 * _911;
              float _915 = _902 + _914;
              _933 = _915;
            } else {
              float _917 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _918 = _602 - (User_000.UserConstant_Z_000[9].z);
              float _919 = max(9.999999974752427e-07f, _917);
              float _920 = _918 / _919;
              float _921 = 1.0f - _920;
              float _922 = _921 * (User_000.UserConstant_Z_000[9].w);
              float _923 = _922 + _920;
              float _924 = _921 * _921;
              float _925 = _924 * _921;
              float _926 = _925 - _921;
              float _927 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _928 = _917 * _917;
              float _929 = _928 * _927;
              float _930 = _929 * _926;
              float _931 = _923 + _930;
              _933 = _931;
            }
          }
        }
      }
      float _934 = saturate(_933);
      _936 = _726;
      _937 = _830;
      _938 = _934;
    } else {
      _936 = _600;
      _937 = _601;
      _938 = _602;
    }
    int _939 = _604 & 2;
    bool _940 = (_939 == 0);
    if (!_940) {
      float _942 = sqrt(_936);
      float _943 = sqrt(_937);
      float _944 = sqrt(_938);
      float _945 = dot(float3(_942, _943, _944), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
      float _946 = 1.0f - _945;
      float _947 = saturate(_946);
      _949 = _947;
    } else {
      _949 = 1.0f;
    }
    int _950 = _604 & 8;
    bool _951 = (_950 == 0);
    if (_951) {
      int _953 = _604 & 4;
      bool _954 = (_953 == 0);
      if (!_954) {
        int _956 = _604 & 16;
        bool _957 = (_956 == 0);
        if (!_957) {
          float _961 = (User_000.UserConstant_Z_000[5].x) * 0.5f;
          float _962 = _961 + 0.5f;
          bool _963 = (_962 < 0.5f);
          float _964 = (User_000.UserConstant_Z_000[5].x) * 5.0f;
          float _965 = select(_963, (User_000.UserConstant_Z_000[5].x), _964);
          bool _966 = (_937 < _938);
          float _967 = select(_966, _938, _937);
          float _968 = select(_966, _937, _938);
          bool _969 = (_936 < _967);
          float _970 = select(_969, _967, _936);
          float _971 = select(_969, _936, _967);
          float _972 = min(_971, _968);
          float _973 = _970 - _972;
          float _974 = _970 + 1.000000013351432e-10f;
          float _975 = _973 / _974;
          float _977 = _975 - (User_000.UserConstant_Z_000[5].y);
          float _978 = saturate(_977);
          float _979 = max(_978, 9.999999974752427e-07f);
          float _980 = log2(_979);
          float _981 = _980 * _965;
          float _982 = exp2(_981);
          float _983 = 2.0f - _982;
          float _985 = 1.0f - (User_000.UserConstant_Z_000[5].z);
          float _986 = saturate(_985);
          float _987 = max(_986, _983);
          float _988 = dot(float3(_936, _937, _938), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
          float _989 = _936 - _988;
          float _990 = _937 - _988;
          float _991 = _938 - _988;
          float _992 = _989 * _987;
          float _993 = _990 * _987;
          float _994 = _991 * _987;
          float _995 = _988 - _936;
          float _996 = _995 + _992;
          float _997 = _988 - _937;
          float _998 = _997 + _993;
          float _999 = _988 - _938;
          float _1000 = _999 + _994;
          float _1001 = _996 * _949;
          float _1002 = _998 * _949;
          float _1003 = _1000 * _949;
          float _1004 = _1001 + _936;
          float _1005 = _1002 + _937;
          float _1006 = _1003 + _938;
          _1123 = _1004;
          _1124 = _1005;
          _1125 = _1006;
        } else {
          bool _1008 = (_949 == 0.0f);
          if (!_1008) {
            float _1012 = abs(User_000.UserConstant_Z_000[5].x);
            float _1013 = saturate(_1012);
            uint4 _1015 = 0u; t15.GetDimensions(0u, _1015.x, _1015.y, _1015.w);
            float _1018 = float((uint)_1015.y);
            int _1019 = _604 & 32;
            bool _1020 = (_1019 == 0);
            float _1021 = _1018 + -1.0f;
            if (!_1020) {
              float _1023 = 1.0f / _1021;
              uint _1024 = uint(SV_Position.x);
              uint _1025 = uint(SV_Position.y);
              int _1026 = _1024 & 63;
              int _1027 = _1025 & 63;
              float4 _1029 = t6.Load(int4(_1026, _1027, 0, 0));
              float _1032 = _1029.x + -0.5f;
              float _1033 = _936 * 13.999999046325684f;
              float _1034 = _937 * 13.999999046325684f;
              float _1035 = _938 * 13.999999046325684f;
              float _1036 = saturate(_1033);
              float _1037 = saturate(_1034);
              float _1038 = saturate(_1035);
              float _1039 = _936 + -0.9285714030265808f;
              float _1040 = _937 + -0.9285714030265808f;
              float _1041 = _938 + -0.9285714030265808f;
              float _1042 = _1039 * 13.999999046325684f;
              float _1043 = _1040 * 13.999999046325684f;
              float _1044 = _1041 * 13.999999046325684f;
              float _1045 = saturate(_1042);
              float _1046 = saturate(_1043);
              float _1047 = saturate(_1044);
              float _1048 = 1.0f - _1045;
              float _1049 = 1.0f - _1046;
              float _1050 = 1.0f - _1047;
              float _1051 = min(_1036, _1048);
              float _1052 = min(_1037, _1049);
              float _1053 = min(_1038, _1050);
              float _1054 = _1029.y + -0.5f;
              float _1055 = _1051 * _1054;
              float _1056 = _1052 * _1054;
              float _1057 = _1053 * _1054;
              float _1058 = _1055 + _1032;
              float _1059 = _1056 + _1032;
              float _1060 = _1057 + _1032;
              float _1061 = _1058 * _1023;
              float _1062 = _1059 * _1023;
              float _1063 = _1060 * _1023;
              float _1064 = _1061 + _936;
              float _1065 = _1062 + _937;
              float _1066 = _1063 + _938;
              float _1067 = saturate(_1064);
              float _1068 = saturate(_1065);
              float _1069 = saturate(_1066);
              float _1070 = saturate(_1067);
              float _1071 = saturate(_1068);
              float _1072 = saturate(_1069);
              _1074 = _1070;
              _1075 = _1071;
              _1076 = _1072;
            } else {
              _1074 = _936;
              _1075 = _937;
              _1076 = _938;
            }
            float _1077 = float((uint)_1015.x);
            float _1078 = _1021 / _1077;
            float _1079 = _1078 * _1074;
            float _1080 = 0.5f / _1077;
            float _1081 = _1079 + _1080;
            float _1082 = _1021 / _1018;
            float _1083 = _1082 * _1075;
            float _1084 = 0.5f / _1018;
            float _1085 = _1083 + _1084;
            float _1086 = _1076 * _1021;
            float _1087 = floor(_1086);
            float _1088 = frac(_1086);
            float _1089 = _1087 / _1018;
            float _1090 = _1089 + _1081;
            float _1091 = _1087 + 1.0f;
            float _1092 = _1091 / _1018;
            float _1093 = _1092 + _1081;
            float4 _1095 = t15.Sample(s0, float2(_1090, _1085));
            float4 _1099 = t15.Sample(s0, float2(_1093, _1085));
            float _1103 = _1099.x - _1095.x;
            float _1104 = _1099.y - _1095.y;
            float _1105 = _1099.z - _1095.z;
            float _1106 = _1103 * _1088;
            float _1107 = _1104 * _1088;
            float _1108 = _1105 * _1088;
            float _1109 = _1013 * _949;
            float _1110 = _1095.x - _936;
            float _1111 = _1110 + _1106;
            float _1112 = _1095.y - _937;
            float _1113 = _1112 + _1107;
            float _1114 = _1095.z - _938;
            float _1115 = _1114 + _1108;
            float _1116 = _1111 * _1109;
            float _1117 = _1113 * _1109;
            float _1118 = _1115 * _1109;
            float _1119 = _1116 + _936;
            float _1120 = _1117 + _937;
            float _1121 = _1118 + _938;
            _1123 = _1119;
            _1124 = _1120;
            _1125 = _1121;
          } else {
            _1123 = _936;
            _1124 = _937;
            _1125 = _938;
          }
        }
      } else {
        _1123 = _936;
        _1124 = _937;
        _1125 = _938;
      }
    } else {
      _1123 = _949;
      _1124 = _949;
      _1125 = _949;
    }
    float _1126 = _1123 * 13.450128555297852f;
    float _1127 = _1124 * 13.450128555297852f;
    float _1128 = _1125 * 13.450128555297852f;
    float _1129 = exp2(_1126);
    float _1130 = exp2(_1127);
    float _1131 = exp2(_1128);
    float _1132 = _1129 + -1.0f;
    float _1133 = _1130 + -1.0f;
    float _1134 = _1131 + -1.0f;
    float _1135 = _1132 * _582;
    float _1136 = _1133 * _582;
    float _1137 = _1134 * _582;
    _1139 = _1135;
    _1140 = _1136;
    _1141 = _1137;
  } else {
    _1139 = _583;
    _1140 = _584;
    _1141 = _585;
  }
  float _1146 = (User_000.UserConstant_Z_000[8].x) * _1139;
  float _1147 = (User_000.UserConstant_Z_000[8].y) * _1140;
  float _1148 = (User_000.UserConstant_Z_000[8].z) * _1141;
  float3 resonance_perceptual_film_grain = ResonanceApplyPerceptualFilmGrain(
      float3(_1146, _1147, _1148),
      SV_Position.xy);
  float _1153 = (PostProcess_000.PostProcessConstant_Z_000[10].z) * TEXCOORD.x;
  float _1154 = _1153 * (PostProcess_000.PostProcessConstant_Z_000[9].x);
  float _1155 = (PostProcess_000.PostProcessConstant_Z_000[10].z) * TEXCOORD.y;
  float _1156 = _1155 * (PostProcess_000.PostProcessConstant_Z_000[9].y);
  float _1159 = _1154 + (PostProcess_000.PostProcessConstant_Z_000[9].z);
  float _1160 = _1156 + (PostProcess_000.PostProcessConstant_Z_000[9].w);
  float4 _1163 = t9.Sample(s9, float2(_1159, _1160));
  float _1167 = dot(float3(_1146, _1147, _1148), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  bool _1170 = ((PostProcess_000.PostProcessConstant_Z_000[10].x) > 0.0f);
  int _1173 = asint((Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[1].w));
  int _1174 = select(_1170, _1173, 0);
  float _1175 = (PostProcess_000.PostProcessConstant_Z_000[10].z) * SV_Position.x;
  float _1176 = (PostProcess_000.PostProcessConstant_Z_000[10].z) * SV_Position.y;
  uint _1177 = uint(_1175);
  uint _1178 = uint(_1176);
  int _1179 = _1177 & 63;
  int _1180 = _1178 & 63;
  float4 _1182 = t6.Load(int4(_1179, _1180, _1174, 0));
  bool _1184 = ((PostProcess_000.PostProcessConstant_Z_000[10].z) < 1.0f);
  if (_1184) {
    float _1186 = _1175 * 0.015625f;
    float _1187 = _1176 * 0.015625f;
    float _1188 = float((uint)_1173);
    float _1189 = select(_1170, _1188, 0.0f);
    float4 _1191 = t6.SampleLevel(s1, float3(_1186, _1187, _1189), 0.0f);
    float _1193 = _1182.y - _1191.y;
    float _1194 = _1193 * (PostProcess_000.PostProcessConstant_Z_000[10].z);
    float _1195 = _1194 + _1191.y;
    _1197 = _1195;
  } else {
    _1197 = _1182.y;
  }
  float _1198 = _1163.x * -2.0f;
  float _1199 = _1198 * _1197;
  float _1200 = _1197 * 2.0f;
  float _1201 = _1200 * _1163.y;
  float _1202 = _1200 * _1163.z;
  float _1203 = _1199 + _1163.x;
  float _1204 = _1201 - _1163.y;
  float _1205 = _1202 - _1163.z;
  float _1206 = _1203 * _1163.x;
  float _1207 = _1204 * _1163.y;
  float _1208 = _1205 * _1163.z;
  float _1209 = _1167 + 1.0f;
  float _1210 = _1167 / _1209;
  float _1211 = _1210 + -9.999999747378752e-05f;
  float _1212 = _1211 * 1111.111083984375f;
  float _1213 = saturate(_1212);
  float _1214 = _1213 * 2.0f;
  float _1215 = 3.0f - _1214;
  float _1216 = _1213 * _1213;
  float _1217 = _1216 * _1215;
  bool _1219 = ((PostProcess_000.PostProcessConstant_Z_000[10].y) > 0.0f);
  float _1220 = float((bool)_1219);
  float _1221 = dot(float3(_1206, _1207, _1208), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  float _1222 = _1221 - _1206;
  float _1223 = _1221 - _1207;
  float _1224 = _1221 - _1208;
  float _1225 = _1222 * _1220;
  float _1226 = _1223 * _1220;
  float _1227 = _1224 * _1220;
  float _1228 = _1225 + _1206;
  float _1229 = _1226 + _1207;
  float _1230 = _1227 + _1208;
  float _1234 = (PostProcess_000.PostProcessConstant_Z_000[2].y) - (PostProcess_000.PostProcessConstant_Z_000[2].x);
  float _1235 = _1234 * _1210;
  float _1236 = _1235 + (PostProcess_000.PostProcessConstant_Z_000[2].x);
  float _1237 = _1217 * _1236;
  float _1238 = _1237 * _1228;
  float _1239 = _1237 * _1229;
  float _1240 = _1237 * _1230;
  float _1241 = _1238 + _1146;
  float _1242 = _1239 + _1147;
  float _1243 = _1240 + _1148;
  float _1244 = max(0.0f, _1241);
  float _1245 = max(0.0f, _1242);
  float _1246 = max(0.0f, _1243);
  float3 resonance_film_grain_output = ResonanceSelectFilmGrainOutput(
      float3(_1244, _1245, _1246),
      resonance_perceptual_film_grain);
  _1244 = resonance_film_grain_output.x;
  _1245 = resonance_film_grain_output.y;
  _1246 = resonance_film_grain_output.z;
  float _1249 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 2.0f;
  float _1250 = log2(_1244);
  float _1251 = _1249 * _1250;
  float _1252 = exp2(_1251);
  float _1253 = _1252 + -1.0f;
  float _1254 = _1244 + -1.0f;
  float _1255 = _1253 / _1254;
  bool _1256 = !(_1244 == 1.0f);
  float _1257 = _1255 + -1.0f;
  float _1258 = _1257 / _1255;
  float _1259 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _1260 = _1259 / _1249;
  float _1261 = select(_1256, _1258, _1260);
  float _1262 = log2(_1245);
  float _1263 = _1262 * _1249;
  float _1264 = exp2(_1263);
  float _1265 = _1264 + -1.0f;
  float _1266 = _1245 + -1.0f;
  float _1267 = _1265 / _1266;
  bool _1268 = !(_1245 == 1.0f);
  float _1269 = _1267 + -1.0f;
  float _1270 = _1269 / _1267;
  float _1271 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _1272 = _1271 / _1249;
  float _1273 = select(_1268, _1270, _1272);
  float _1274 = log2(_1246);
  float _1275 = _1274 * _1249;
  float _1276 = exp2(_1275);
  float _1277 = _1276 + -1.0f;
  float _1278 = _1246 + -1.0f;
  float _1279 = _1277 / _1278;
  bool _1280 = !(_1246 == 1.0f);
  float _1281 = _1279 + -1.0f;
  float _1282 = _1281 / _1279;
  float _1283 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _1284 = _1283 / _1249;
  float _1285 = select(_1280, _1282, _1284);
  float3 resonance_post_process_output = ResonanceApplyPostProcessToneMap(
      float3(_1244, _1245, _1246),
      float3(_1261, _1273, _1285),
      true);
  float _1286 = resonance_post_process_output.x;
  float _1287 = resonance_post_process_output.y;
  float _1288 = resonance_post_process_output.z;
  float _1289 = log2(_1286);
  float _1290 = log2(_1287);
  float _1291 = log2(_1288);
  float _1292 = _1289 * 0.4166666567325592f;
  float _1293 = _1290 * 0.4166666567325592f;
  float _1294 = _1291 * 0.4166666567325592f;
  float _1295 = exp2(_1292);
  float _1296 = exp2(_1293);
  float _1297 = exp2(_1294);
  float _1298 = _1295 * 1.0549999475479126f;
  float _1299 = _1296 * 1.0549999475479126f;
  float _1300 = _1297 * 1.0549999475479126f;
  float _1301 = _1298 + -0.054999999701976776f;
  float _1302 = _1299 + -0.054999999701976776f;
  float _1303 = _1300 + -0.054999999701976776f;
  float _1304 = _1286 * 12.920000076293945f;
  float _1305 = _1287 * 12.920000076293945f;
  float _1306 = _1288 * 12.920000076293945f;
  bool _1307 = (_1286 <= 0.0031308000907301903f);
  bool _1308 = (_1287 <= 0.0031308000907301903f);
  bool _1309 = (_1288 <= 0.0031308000907301903f);
  float _1310 = select(_1307, _1304, _1301);
  float _1311 = select(_1308, _1305, _1302);
  float _1312 = select(_1309, _1306, _1303);
  uint _1313 = uint(SV_Position.x);
  uint _1314 = uint(SV_Position.y);
  int _1315 = _1313 & 63;
  int _1316 = _1314 & 63;
  float4 _1318 = t1.Load(int4(_1315, _1316, _1173, 0));
  float _1320 = _1318.x + -0.5f;
  float _1321 = _1320 * 0.003921568859368563f;
  float _1322 = _1321 + _1310;
  float _1323 = _1321 + _1311;
  float _1324 = _1321 + _1312;
  float _1325 = saturate(_1322);
  float _1326 = saturate(_1323);
  float _1327 = saturate(_1324);
  SV_Target.x = _1325;
  SV_Target.y = _1326;
  SV_Target.z = _1327;
  SV_Target.w = _135.w;
  if (ResonanceIsPsychoV()) {
    SV_Target.rgb = ResonanceRenderIntermediatePassDithered(
        resonance_post_process_output, SV_Position.xy);
  }
  return SV_Target;
}