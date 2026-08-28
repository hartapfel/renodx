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
  int _143 = asint((User_000.UserConstant_Z_000[7].z));
  bool _144 = ((int)_143 > (int)0);
  float _173;
  float _257;
  float _294;
  float _490;
  float _529;
  float _530;
  float _531;
  float _570;
  float _571;
  float _572;
  float _775;
  float _879;
  float _983;
  float _986;
  float _987;
  float _988;
  float _999;
  float _1124;
  float _1125;
  float _1126;
  float _1173;
  float _1174;
  float _1175;
  float _1189;
  float _1190;
  float _1191;
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
      _529 = _326;
      _530 = _139;
      _531 = _333;
    } else {
      _529 = _138;
      _530 = _139;
      _531 = _140;
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
      _529 = _379;
      _530 = _380;
      _531 = _381;
    } else {
      int _384 = asint((User_000.UserConstant_Z_000[7].x));
      bool _385 = ((int)_384 > (int)0);
      [branch]
      if (_385) {
        float4 _389 = t7.Sample(s7, float2(TEXCOORD.x, TEXCOORD.y));
        float _391 = abs(_389.x);
        _490 = _391;
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
        float4 _450 = t7.Load(int3(0, 0, 0));
        float _455 = _450.x - (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
        float _456 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _455;
        float _459 = (PostProcess_000.PostProcessConstant_Z_000[6].w) * _456;
        float _460 = _459 + _456;
        float _461 = _456 - _459;
        float _462 = max(_445, _461);
        float _463 = min(_462, _460);
        float _466 = _445 - _463;
        float _467 = (PostProcess_000.PostProcessConstant_Z_000[5].w) * _466;
        float _469 = _463 - (PostProcess_000.PostProcessConstant_Z_000[5].y);
        float _470 = _469 * _445;
        float _471 = _467 / _470;
        float _472 = min(_471, 0.0f);
        float _475 = _459 + 1.0f;
        float _476 = 1.0f / _475;
        float _477 = (PostProcess_000.PostProcessConstant_Z_000[7].z) * _472;
        float _478 = max(0.0f, _471);
        float _481 = (PostProcess_000.PostProcessConstant_Z_000[18].x) * _478;
        float _482 = _481 + _477;
        float _483 = _482 * _476;
        float _484 = min(_448.x, _483);
        float _485 = abs(_484);
        float _486 = abs(_483);
        float _487 = max(_485, _486);
        float _488 = saturate(_487);
        _490 = _488;
      }
      float _493 = (PostProcess_000.PostProcessConstant_Z_000[6].x) * _490;
      float4 _496 = t4.Sample(s4, float2(TEXCOORD.x, TEXCOORD.y));
      float _503 = (PostProcess_000.PostProcessConstant_Z_000[7].x) * _493;
      float _504 = (PostProcess_000.PostProcessConstant_Z_000[7].y) * _493;
      float _505 = _503 + TEXCOORD.x;
      float _506 = _504 + TEXCOORD.y;
      float4 _507 = t4.Sample(s4, float2(_505, _506));
      float4 _511 = t5.Sample(s5, float2(_505, _506));
      float _513 = abs(_511.x);
      float _514 = _507.z - _496.z;
      float _515 = _513 * _514;
      float _516 = _493 + -1.0f;
      float _517 = saturate(_516);
      float _518 = _496.x - _138;
      float _519 = _496.y - _139;
      float _520 = _496.z - _140;
      float _521 = _520 + _515;
      float _522 = _517 * _518;
      float _523 = _517 * _519;
      float _524 = _521 * _517;
      float _525 = _522 + _138;
      float _526 = _523 + _139;
      float _527 = _524 + _140;
      _529 = _525;
      _530 = _526;
      _531 = _527;
    }
  }
  float4 _533 = t12.SampleLevel(s0, float2(_57, _58), 0.0f);
  float4 _539 = t8.Sample(s8, float2(_59, _60));
  bool _545 = !((PostProcess_000.PostProcessConstant_Z_000[17].z) >= -1.0f);
  float _549 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _539.x;
  float _550 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _539.y;
  float _551 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _539.z;
  float _552 = _549 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
  float _553 = _550 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
  float _554 = _551 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
  if (!_545) {
    float _556 = _552 * _533.x;
    float _557 = _553 * _533.y;
    float _558 = _554 * _533.z;
    _570 = _556;
    _571 = _557;
    _572 = _558;
  } else {
    float _560 = saturate(_552);
    float _561 = saturate(_553);
    float _562 = saturate(_554);
    float _563 = _533.x - _529;
    float _564 = _533.y - _530;
    float _565 = _533.z - _531;
    float _566 = _560 * _563;
    float _567 = _561 * _564;
    float _568 = _562 * _565;
    _570 = _566;
    _571 = _567;
    _572 = _568;
  }
  float _573 = _570 + _529;
  float _574 = _571 + _530;
  float _575 = _572 + _531;
  float4 _579 = t17.Load(int3(0, 0, 0));
  float _587 = (PostProcess_000.PostProcessConstant_Z_000[10].w) * 9.999999747378752e-05f;
  float _588 = (Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[87].y) * 11190.6005859375f;
  float _589 = _579.x * _588;
  float _590 = _589 * _573;
  float _591 = _590 * (PostProcess_000.PostProcessConstant_Z_000[14].x);
  float _592 = _591 * _587;
  float _593 = _589 * _574;
  float _594 = _593 * (PostProcess_000.PostProcessConstant_Z_000[14].y);
  float _595 = _594 * _587;
  float _596 = _589 * _575;
  float _597 = _596 * (PostProcess_000.PostProcessConstant_Z_000[14].z);
  float _598 = _597 * _587;
  float _599 = _592 + 1.0f;
  float _600 = _595 + 1.0f;
  float _601 = _598 + 1.0f;
  float _602 = log2(_599);
  float _603 = log2(_600);
  float _604 = log2(_601);
  float _607 = (PostProcess_000.PostProcessConstant_Z_320[0].x) * 0.07434873282909393f;
  float _608 = _607 * _602;
  float _609 = _607 * _603;
  float _610 = _607 * _604;
  float _612 = _608 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _613 = _609 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _614 = _610 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float4 _617 = t3.Sample(s3, float3(_612, _613, _614));
  float _623 = _617.x * 13.450128555297852f;
  float _624 = _617.y * 13.450128555297852f;
  float _625 = _617.z * 13.450128555297852f;
  float _626 = exp2(_623);
  float _627 = exp2(_624);
  float _628 = exp2(_625);
  float _629 = _626 + -1.0f;
  float _630 = _627 + -1.0f;
  float _631 = _628 + -1.0f;
  float _632 = 0.8936070799827576f / (PostProcess_000.PostProcessConstant_Z_000[10].w);
  float _633 = _632 * _629;
  float _634 = _632 * _630;
  float _635 = _632 * _631;
  float3 resonance_scaled_lut_output = ResonanceApplyPostProcessLUT(
      float3(_592 * _632, _595 * _632, _598 * _632),
      float3(_633, _634, _635),
      1.f.xxx);
  _633 = resonance_scaled_lut_output.x;
  _634 = resonance_scaled_lut_output.y;
  _635 = resonance_scaled_lut_output.z;
  bool _638 = ((User_000.UserConstant_Z_000[3].x) > 0.0f) && !ResonanceIsPsychoV();
  if (_638) {
    float _640 = (PostProcess_000.PostProcessConstant_Z_000[10].w) * 1.1190600395202637f;
    float _641 = _633 * _640;
    float _642 = _634 * _640;
    float _643 = _635 * _640;
    float _644 = _641 + 1.0f;
    float _645 = _642 + 1.0f;
    float _646 = _643 + 1.0f;
    float _647 = log2(_644);
    float _648 = log2(_645);
    float _649 = log2(_646);
    float _650 = _647 * 0.07434873282909393f;
    float _651 = _648 * 0.07434873282909393f;
    float _652 = _649 * 0.07434873282909393f;
    int _654 = asint((User_000.UserConstant_Z_000[3].y));
    int _655 = _654 & 1;
    bool _656 = (_655 == 0);
    if (!_656) {
      bool _673 = !(_650 <= (User_000.UserConstant_Z_000[4].x));
      if (!_673) {
        float _675 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _676 = _650 / _675;
        float _677 = _676 * (User_000.UserConstant_Z_000[4].y);
        float _678 = _676 * _676;
        float _679 = _678 * _676;
        float _680 = _679 - _676;
        float _681 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _682 = _675 * _675;
        float _683 = _682 * _681;
        float _684 = _683 * _680;
        float _685 = _684 + _677;
        _775 = _685;
      } else {
        bool _687 = !(_650 <= (User_000.UserConstant_Z_000[4].z));
        if (!_687) {
          float _689 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _690 = max(9.999999974752427e-07f, _689);
          float _691 = _650 - (User_000.UserConstant_Z_000[4].x);
          float _692 = _691 / _690;
          float _693 = 1.0f - _692;
          float _694 = _693 * (User_000.UserConstant_Z_000[4].y);
          float _695 = _692 * (User_000.UserConstant_Z_000[4].w);
          float _696 = _694 + _695;
          float _697 = _693 * _693;
          float _698 = _697 * _693;
          float _699 = _698 - _693;
          float _700 = _699 * (User_000.UserConstant_Z_000[10].x);
          float _701 = _692 * _692;
          float _702 = _701 * _692;
          float _703 = _702 - _692;
          float _704 = _703 * (User_000.UserConstant_Z_000[10].y);
          float _705 = _700 + _704;
          float _706 = _690 * _690;
          float _707 = _706 * 0.1666666716337204f;
          float _708 = _707 * _705;
          float _709 = _696 + _708;
          _775 = _709;
        } else {
          bool _711 = !(_650 <= (User_000.UserConstant_Z_000[9].x));
          if (!_711) {
            float _713 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _714 = max(9.999999974752427e-07f, _713);
            float _715 = _650 - (User_000.UserConstant_Z_000[4].z);
            float _716 = _715 / _714;
            float _717 = 1.0f - _716;
            float _718 = _717 * (User_000.UserConstant_Z_000[4].w);
            float _719 = _716 * (User_000.UserConstant_Z_000[9].y);
            float _720 = _718 + _719;
            float _721 = _717 * _717;
            float _722 = _721 * _717;
            float _723 = _722 - _717;
            float _724 = _723 * (User_000.UserConstant_Z_000[10].y);
            float _725 = _716 * _716;
            float _726 = _725 * _716;
            float _727 = _726 - _716;
            float _728 = _727 * (User_000.UserConstant_Z_000[10].z);
            float _729 = _724 + _728;
            float _730 = _714 * _714;
            float _731 = _730 * 0.1666666716337204f;
            float _732 = _731 * _729;
            float _733 = _720 + _732;
            _775 = _733;
          } else {
            bool _735 = !(_650 <= (User_000.UserConstant_Z_000[9].z));
            if (!_735) {
              float _737 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _738 = max(9.999999974752427e-07f, _737);
              float _739 = _650 - (User_000.UserConstant_Z_000[9].x);
              float _740 = _739 / _738;
              float _741 = 1.0f - _740;
              float _742 = _741 * (User_000.UserConstant_Z_000[9].y);
              float _743 = _740 * (User_000.UserConstant_Z_000[9].w);
              float _744 = _742 + _743;
              float _745 = _741 * _741;
              float _746 = _745 * _741;
              float _747 = _746 - _741;
              float _748 = _747 * (User_000.UserConstant_Z_000[10].z);
              float _749 = _740 * _740;
              float _750 = _749 * _740;
              float _751 = _750 - _740;
              float _752 = _751 * (User_000.UserConstant_Z_000[10].w);
              float _753 = _748 + _752;
              float _754 = _738 * _738;
              float _755 = _754 * 0.1666666716337204f;
              float _756 = _755 * _753;
              float _757 = _744 + _756;
              _775 = _757;
            } else {
              float _759 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _760 = _650 - (User_000.UserConstant_Z_000[9].z);
              float _761 = max(9.999999974752427e-07f, _759);
              float _762 = _760 / _761;
              float _763 = 1.0f - _762;
              float _764 = _763 * (User_000.UserConstant_Z_000[9].w);
              float _765 = _764 + _762;
              float _766 = _763 * _763;
              float _767 = _766 * _763;
              float _768 = _767 - _763;
              float _769 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _770 = _759 * _759;
              float _771 = _770 * _769;
              float _772 = _771 * _768;
              float _773 = _765 + _772;
              _775 = _773;
            }
          }
        }
      }
      float _776 = saturate(_775);
      bool _777 = !(_651 <= (User_000.UserConstant_Z_000[4].x));
      if (!_777) {
        float _779 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _780 = _651 / _779;
        float _781 = _780 * (User_000.UserConstant_Z_000[4].y);
        float _782 = _780 * _780;
        float _783 = _782 * _780;
        float _784 = _783 - _780;
        float _785 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _786 = _779 * _779;
        float _787 = _786 * _785;
        float _788 = _787 * _784;
        float _789 = _788 + _781;
        _879 = _789;
      } else {
        bool _791 = !(_651 <= (User_000.UserConstant_Z_000[4].z));
        if (!_791) {
          float _793 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _794 = max(9.999999974752427e-07f, _793);
          float _795 = _651 - (User_000.UserConstant_Z_000[4].x);
          float _796 = _795 / _794;
          float _797 = 1.0f - _796;
          float _798 = _797 * (User_000.UserConstant_Z_000[4].y);
          float _799 = _796 * (User_000.UserConstant_Z_000[4].w);
          float _800 = _798 + _799;
          float _801 = _797 * _797;
          float _802 = _801 * _797;
          float _803 = _802 - _797;
          float _804 = _803 * (User_000.UserConstant_Z_000[10].x);
          float _805 = _796 * _796;
          float _806 = _805 * _796;
          float _807 = _806 - _796;
          float _808 = _807 * (User_000.UserConstant_Z_000[10].y);
          float _809 = _804 + _808;
          float _810 = _794 * _794;
          float _811 = _810 * 0.1666666716337204f;
          float _812 = _811 * _809;
          float _813 = _800 + _812;
          _879 = _813;
        } else {
          bool _815 = !(_651 <= (User_000.UserConstant_Z_000[9].x));
          if (!_815) {
            float _817 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _818 = max(9.999999974752427e-07f, _817);
            float _819 = _651 - (User_000.UserConstant_Z_000[4].z);
            float _820 = _819 / _818;
            float _821 = 1.0f - _820;
            float _822 = _821 * (User_000.UserConstant_Z_000[4].w);
            float _823 = _820 * (User_000.UserConstant_Z_000[9].y);
            float _824 = _822 + _823;
            float _825 = _821 * _821;
            float _826 = _825 * _821;
            float _827 = _826 - _821;
            float _828 = _827 * (User_000.UserConstant_Z_000[10].y);
            float _829 = _820 * _820;
            float _830 = _829 * _820;
            float _831 = _830 - _820;
            float _832 = _831 * (User_000.UserConstant_Z_000[10].z);
            float _833 = _828 + _832;
            float _834 = _818 * _818;
            float _835 = _834 * 0.1666666716337204f;
            float _836 = _835 * _833;
            float _837 = _824 + _836;
            _879 = _837;
          } else {
            bool _839 = !(_651 <= (User_000.UserConstant_Z_000[9].z));
            if (!_839) {
              float _841 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _842 = max(9.999999974752427e-07f, _841);
              float _843 = _651 - (User_000.UserConstant_Z_000[9].x);
              float _844 = _843 / _842;
              float _845 = 1.0f - _844;
              float _846 = _845 * (User_000.UserConstant_Z_000[9].y);
              float _847 = _844 * (User_000.UserConstant_Z_000[9].w);
              float _848 = _846 + _847;
              float _849 = _845 * _845;
              float _850 = _849 * _845;
              float _851 = _850 - _845;
              float _852 = _851 * (User_000.UserConstant_Z_000[10].z);
              float _853 = _844 * _844;
              float _854 = _853 * _844;
              float _855 = _854 - _844;
              float _856 = _855 * (User_000.UserConstant_Z_000[10].w);
              float _857 = _852 + _856;
              float _858 = _842 * _842;
              float _859 = _858 * 0.1666666716337204f;
              float _860 = _859 * _857;
              float _861 = _848 + _860;
              _879 = _861;
            } else {
              float _863 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _864 = _651 - (User_000.UserConstant_Z_000[9].z);
              float _865 = max(9.999999974752427e-07f, _863);
              float _866 = _864 / _865;
              float _867 = 1.0f - _866;
              float _868 = _867 * (User_000.UserConstant_Z_000[9].w);
              float _869 = _868 + _866;
              float _870 = _867 * _867;
              float _871 = _870 * _867;
              float _872 = _871 - _867;
              float _873 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _874 = _863 * _863;
              float _875 = _874 * _873;
              float _876 = _875 * _872;
              float _877 = _869 + _876;
              _879 = _877;
            }
          }
        }
      }
      float _880 = saturate(_879);
      bool _881 = !(_652 <= (User_000.UserConstant_Z_000[4].x));
      if (!_881) {
        float _883 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _884 = _652 / _883;
        float _885 = _884 * (User_000.UserConstant_Z_000[4].y);
        float _886 = _884 * _884;
        float _887 = _886 * _884;
        float _888 = _887 - _884;
        float _889 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _890 = _883 * _883;
        float _891 = _890 * _889;
        float _892 = _891 * _888;
        float _893 = _892 + _885;
        _983 = _893;
      } else {
        bool _895 = !(_652 <= (User_000.UserConstant_Z_000[4].z));
        if (!_895) {
          float _897 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _898 = max(9.999999974752427e-07f, _897);
          float _899 = _652 - (User_000.UserConstant_Z_000[4].x);
          float _900 = _899 / _898;
          float _901 = 1.0f - _900;
          float _902 = _901 * (User_000.UserConstant_Z_000[4].y);
          float _903 = _900 * (User_000.UserConstant_Z_000[4].w);
          float _904 = _902 + _903;
          float _905 = _901 * _901;
          float _906 = _905 * _901;
          float _907 = _906 - _901;
          float _908 = _907 * (User_000.UserConstant_Z_000[10].x);
          float _909 = _900 * _900;
          float _910 = _909 * _900;
          float _911 = _910 - _900;
          float _912 = _911 * (User_000.UserConstant_Z_000[10].y);
          float _913 = _908 + _912;
          float _914 = _898 * _898;
          float _915 = _914 * 0.1666666716337204f;
          float _916 = _915 * _913;
          float _917 = _904 + _916;
          _983 = _917;
        } else {
          bool _919 = !(_652 <= (User_000.UserConstant_Z_000[9].x));
          if (!_919) {
            float _921 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _922 = max(9.999999974752427e-07f, _921);
            float _923 = _652 - (User_000.UserConstant_Z_000[4].z);
            float _924 = _923 / _922;
            float _925 = 1.0f - _924;
            float _926 = _925 * (User_000.UserConstant_Z_000[4].w);
            float _927 = _924 * (User_000.UserConstant_Z_000[9].y);
            float _928 = _926 + _927;
            float _929 = _925 * _925;
            float _930 = _929 * _925;
            float _931 = _930 - _925;
            float _932 = _931 * (User_000.UserConstant_Z_000[10].y);
            float _933 = _924 * _924;
            float _934 = _933 * _924;
            float _935 = _934 - _924;
            float _936 = _935 * (User_000.UserConstant_Z_000[10].z);
            float _937 = _932 + _936;
            float _938 = _922 * _922;
            float _939 = _938 * 0.1666666716337204f;
            float _940 = _939 * _937;
            float _941 = _928 + _940;
            _983 = _941;
          } else {
            bool _943 = !(_652 <= (User_000.UserConstant_Z_000[9].z));
            if (!_943) {
              float _945 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _946 = max(9.999999974752427e-07f, _945);
              float _947 = _652 - (User_000.UserConstant_Z_000[9].x);
              float _948 = _947 / _946;
              float _949 = 1.0f - _948;
              float _950 = _949 * (User_000.UserConstant_Z_000[9].y);
              float _951 = _948 * (User_000.UserConstant_Z_000[9].w);
              float _952 = _950 + _951;
              float _953 = _949 * _949;
              float _954 = _953 * _949;
              float _955 = _954 - _949;
              float _956 = _955 * (User_000.UserConstant_Z_000[10].z);
              float _957 = _948 * _948;
              float _958 = _957 * _948;
              float _959 = _958 - _948;
              float _960 = _959 * (User_000.UserConstant_Z_000[10].w);
              float _961 = _956 + _960;
              float _962 = _946 * _946;
              float _963 = _962 * 0.1666666716337204f;
              float _964 = _963 * _961;
              float _965 = _952 + _964;
              _983 = _965;
            } else {
              float _967 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _968 = _652 - (User_000.UserConstant_Z_000[9].z);
              float _969 = max(9.999999974752427e-07f, _967);
              float _970 = _968 / _969;
              float _971 = 1.0f - _970;
              float _972 = _971 * (User_000.UserConstant_Z_000[9].w);
              float _973 = _972 + _970;
              float _974 = _971 * _971;
              float _975 = _974 * _971;
              float _976 = _975 - _971;
              float _977 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _978 = _967 * _967;
              float _979 = _978 * _977;
              float _980 = _979 * _976;
              float _981 = _973 + _980;
              _983 = _981;
            }
          }
        }
      }
      float _984 = saturate(_983);
      _986 = _776;
      _987 = _880;
      _988 = _984;
    } else {
      _986 = _650;
      _987 = _651;
      _988 = _652;
    }
    int _989 = _654 & 2;
    bool _990 = (_989 == 0);
    if (!_990) {
      float _992 = sqrt(_986);
      float _993 = sqrt(_987);
      float _994 = sqrt(_988);
      float _995 = dot(float3(_992, _993, _994), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
      float _996 = 1.0f - _995;
      float _997 = saturate(_996);
      _999 = _997;
    } else {
      _999 = 1.0f;
    }
    int _1000 = _654 & 8;
    bool _1001 = (_1000 == 0);
    if (_1001) {
      int _1003 = _654 & 4;
      bool _1004 = (_1003 == 0);
      if (!_1004) {
        int _1006 = _654 & 16;
        bool _1007 = (_1006 == 0);
        if (!_1007) {
          float _1011 = (User_000.UserConstant_Z_000[5].x) * 0.5f;
          float _1012 = _1011 + 0.5f;
          bool _1013 = (_1012 < 0.5f);
          float _1014 = (User_000.UserConstant_Z_000[5].x) * 5.0f;
          float _1015 = select(_1013, (User_000.UserConstant_Z_000[5].x), _1014);
          bool _1016 = (_987 < _988);
          float _1017 = select(_1016, _988, _987);
          float _1018 = select(_1016, _987, _988);
          bool _1019 = (_986 < _1017);
          float _1020 = select(_1019, _1017, _986);
          float _1021 = select(_1019, _986, _1017);
          float _1022 = min(_1021, _1018);
          float _1023 = _1020 - _1022;
          float _1024 = _1020 + 1.000000013351432e-10f;
          float _1025 = _1023 / _1024;
          float _1027 = _1025 - (User_000.UserConstant_Z_000[5].y);
          float _1028 = saturate(_1027);
          float _1029 = max(_1028, 9.999999974752427e-07f);
          float _1030 = log2(_1029);
          float _1031 = _1030 * _1015;
          float _1032 = exp2(_1031);
          float _1033 = 2.0f - _1032;
          float _1035 = 1.0f - (User_000.UserConstant_Z_000[5].z);
          float _1036 = saturate(_1035);
          float _1037 = max(_1036, _1033);
          float _1038 = dot(float3(_986, _987, _988), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
          float _1039 = _986 - _1038;
          float _1040 = _987 - _1038;
          float _1041 = _988 - _1038;
          float _1042 = _1039 * _1037;
          float _1043 = _1040 * _1037;
          float _1044 = _1041 * _1037;
          float _1045 = _1038 - _986;
          float _1046 = _1045 + _1042;
          float _1047 = _1038 - _987;
          float _1048 = _1047 + _1043;
          float _1049 = _1038 - _988;
          float _1050 = _1049 + _1044;
          float _1051 = _1046 * _999;
          float _1052 = _1048 * _999;
          float _1053 = _1050 * _999;
          float _1054 = _1051 + _986;
          float _1055 = _1052 + _987;
          float _1056 = _1053 + _988;
          _1173 = _1054;
          _1174 = _1055;
          _1175 = _1056;
        } else {
          bool _1058 = (_999 == 0.0f);
          if (!_1058) {
            float _1062 = abs(User_000.UserConstant_Z_000[5].x);
            float _1063 = saturate(_1062);
            uint4 _1065 = 0u; t15.GetDimensions(0u, _1065.x, _1065.y, _1065.w);
            float _1068 = float((uint)_1065.y);
            int _1069 = _654 & 32;
            bool _1070 = (_1069 == 0);
            float _1071 = _1068 + -1.0f;
            if (!_1070) {
              float _1073 = 1.0f / _1071;
              uint _1074 = uint(SV_Position.x);
              uint _1075 = uint(SV_Position.y);
              int _1076 = _1074 & 63;
              int _1077 = _1075 & 63;
              float4 _1079 = t6.Load(int4(_1076, _1077, 0, 0));
              float _1082 = _1079.x + -0.5f;
              float _1083 = _986 * 13.999999046325684f;
              float _1084 = _987 * 13.999999046325684f;
              float _1085 = _988 * 13.999999046325684f;
              float _1086 = saturate(_1083);
              float _1087 = saturate(_1084);
              float _1088 = saturate(_1085);
              float _1089 = _986 + -0.9285714030265808f;
              float _1090 = _987 + -0.9285714030265808f;
              float _1091 = _988 + -0.9285714030265808f;
              float _1092 = _1089 * 13.999999046325684f;
              float _1093 = _1090 * 13.999999046325684f;
              float _1094 = _1091 * 13.999999046325684f;
              float _1095 = saturate(_1092);
              float _1096 = saturate(_1093);
              float _1097 = saturate(_1094);
              float _1098 = 1.0f - _1095;
              float _1099 = 1.0f - _1096;
              float _1100 = 1.0f - _1097;
              float _1101 = min(_1086, _1098);
              float _1102 = min(_1087, _1099);
              float _1103 = min(_1088, _1100);
              float _1104 = _1079.y + -0.5f;
              float _1105 = _1101 * _1104;
              float _1106 = _1102 * _1104;
              float _1107 = _1103 * _1104;
              float _1108 = _1105 + _1082;
              float _1109 = _1106 + _1082;
              float _1110 = _1107 + _1082;
              float _1111 = _1108 * _1073;
              float _1112 = _1109 * _1073;
              float _1113 = _1110 * _1073;
              float _1114 = _1111 + _986;
              float _1115 = _1112 + _987;
              float _1116 = _1113 + _988;
              float _1117 = saturate(_1114);
              float _1118 = saturate(_1115);
              float _1119 = saturate(_1116);
              float _1120 = saturate(_1117);
              float _1121 = saturate(_1118);
              float _1122 = saturate(_1119);
              _1124 = _1120;
              _1125 = _1121;
              _1126 = _1122;
            } else {
              _1124 = _986;
              _1125 = _987;
              _1126 = _988;
            }
            float _1127 = float((uint)_1065.x);
            float _1128 = _1071 / _1127;
            float _1129 = _1128 * _1124;
            float _1130 = 0.5f / _1127;
            float _1131 = _1129 + _1130;
            float _1132 = _1071 / _1068;
            float _1133 = _1132 * _1125;
            float _1134 = 0.5f / _1068;
            float _1135 = _1133 + _1134;
            float _1136 = _1126 * _1071;
            float _1137 = floor(_1136);
            float _1138 = frac(_1136);
            float _1139 = _1137 / _1068;
            float _1140 = _1139 + _1131;
            float _1141 = _1137 + 1.0f;
            float _1142 = _1141 / _1068;
            float _1143 = _1142 + _1131;
            float4 _1145 = t15.Sample(s0, float2(_1140, _1135));
            float4 _1149 = t15.Sample(s0, float2(_1143, _1135));
            float _1153 = _1149.x - _1145.x;
            float _1154 = _1149.y - _1145.y;
            float _1155 = _1149.z - _1145.z;
            float _1156 = _1153 * _1138;
            float _1157 = _1154 * _1138;
            float _1158 = _1155 * _1138;
            float _1159 = _1063 * _999;
            float _1160 = _1145.x - _986;
            float _1161 = _1160 + _1156;
            float _1162 = _1145.y - _987;
            float _1163 = _1162 + _1157;
            float _1164 = _1145.z - _988;
            float _1165 = _1164 + _1158;
            float _1166 = _1161 * _1159;
            float _1167 = _1163 * _1159;
            float _1168 = _1165 * _1159;
            float _1169 = _1166 + _986;
            float _1170 = _1167 + _987;
            float _1171 = _1168 + _988;
            _1173 = _1169;
            _1174 = _1170;
            _1175 = _1171;
          } else {
            _1173 = _986;
            _1174 = _987;
            _1175 = _988;
          }
        }
      } else {
        _1173 = _986;
        _1174 = _987;
        _1175 = _988;
      }
    } else {
      _1173 = _999;
      _1174 = _999;
      _1175 = _999;
    }
    float _1176 = _1173 * 13.450128555297852f;
    float _1177 = _1174 * 13.450128555297852f;
    float _1178 = _1175 * 13.450128555297852f;
    float _1179 = exp2(_1176);
    float _1180 = exp2(_1177);
    float _1181 = exp2(_1178);
    float _1182 = _1179 + -1.0f;
    float _1183 = _1180 + -1.0f;
    float _1184 = _1181 + -1.0f;
    float _1185 = _1182 * _632;
    float _1186 = _1183 * _632;
    float _1187 = _1184 * _632;
    _1189 = _1185;
    _1190 = _1186;
    _1191 = _1187;
  } else {
    _1189 = _633;
    _1190 = _634;
    _1191 = _635;
  }
  float3 resonance_perceptual_film_grain = ResonanceApplyPerceptualFilmGrain(
      float3((User_000.UserConstant_Z_000[8].x) * _1189, (User_000.UserConstant_Z_000[8].y) * _1190, (User_000.UserConstant_Z_000[8].z) * _1191),
      SV_Position.xy);
  float _1198 = resonance_perceptual_film_grain.x;
  float _1199 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 2.0f;
  float _1200 = log2(_1198);
  float _1201 = _1199 * _1200;
  float _1202 = exp2(_1201);
  float _1203 = _1202 + -1.0f;
  float _1204 = _1198 + -1.0f;
  float _1205 = _1203 / _1204;
  bool _1206 = !(_1198 == 1.0f);
  float _1207 = _1205 + -1.0f;
  float _1208 = _1207 / _1205;
  float _1209 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _1210 = _1209 / _1199;
  float _1211 = select(_1206, _1208, _1210);
  float _1212 = resonance_perceptual_film_grain.y;
  float _1213 = log2(_1212);
  float _1214 = _1213 * _1199;
  float _1215 = exp2(_1214);
  float _1216 = _1215 + -1.0f;
  float _1217 = _1212 + -1.0f;
  float _1218 = _1216 / _1217;
  bool _1219 = !(_1212 == 1.0f);
  float _1220 = _1218 + -1.0f;
  float _1221 = _1220 / _1218;
  float _1222 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _1223 = _1222 / _1199;
  float _1224 = select(_1219, _1221, _1223);
  float _1225 = resonance_perceptual_film_grain.z;
  float _1226 = log2(_1225);
  float _1227 = _1226 * _1199;
  float _1228 = exp2(_1227);
  float _1229 = _1228 + -1.0f;
  float _1230 = _1225 + -1.0f;
  float _1231 = _1229 / _1230;
  bool _1232 = !(_1225 == 1.0f);
  float _1233 = _1231 + -1.0f;
  float _1234 = _1233 / _1231;
  float _1235 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _1236 = _1235 / _1199;
  float _1237 = select(_1232, _1234, _1236);
  float3 resonance_post_process_output = ResonanceApplyPostProcessToneMap(
      float3(_1198, _1212, _1225),
      float3(_1211, _1224, _1237),
      true);
  float _1238 = resonance_post_process_output.x;
  float _1239 = resonance_post_process_output.y;
  float _1240 = resonance_post_process_output.z;
  float _1241 = log2(_1238);
  float _1242 = log2(_1239);
  float _1243 = log2(_1240);
  float _1244 = _1241 * 0.4166666567325592f;
  float _1245 = _1242 * 0.4166666567325592f;
  float _1246 = _1243 * 0.4166666567325592f;
  float _1247 = exp2(_1244);
  float _1248 = exp2(_1245);
  float _1249 = exp2(_1246);
  float _1250 = _1247 * 1.0549999475479126f;
  float _1251 = _1248 * 1.0549999475479126f;
  float _1252 = _1249 * 1.0549999475479126f;
  float _1253 = _1250 + -0.054999999701976776f;
  float _1254 = _1251 + -0.054999999701976776f;
  float _1255 = _1252 + -0.054999999701976776f;
  float _1256 = _1238 * 12.920000076293945f;
  float _1257 = _1239 * 12.920000076293945f;
  float _1258 = _1240 * 12.920000076293945f;
  bool _1259 = (_1238 <= 0.0031308000907301903f);
  bool _1260 = (_1239 <= 0.0031308000907301903f);
  bool _1261 = (_1240 <= 0.0031308000907301903f);
  float _1262 = select(_1259, _1256, _1253);
  float _1263 = select(_1260, _1257, _1254);
  float _1264 = select(_1261, _1258, _1255);
  int _1267 = asint((Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[1].w));
  uint _1268 = uint(SV_Position.x);
  uint _1269 = uint(SV_Position.y);
  int _1270 = _1268 & 63;
  int _1271 = _1269 & 63;
  float4 _1273 = t1.Load(int4(_1270, _1271, _1267, 0));
  float _1275 = _1273.x + -0.5f;
  float _1276 = _1275 * 0.003921568859368563f;
  float _1277 = _1276 + _1262;
  float _1278 = _1276 + _1263;
  float _1279 = _1276 + _1264;
  float _1280 = saturate(_1277);
  float _1281 = saturate(_1278);
  float _1282 = saturate(_1279);
  SV_Target.x = _1280;
  SV_Target.y = _1281;
  SV_Target.z = _1282;
  SV_Target.w = _135.w;
  if (ResonanceIsPsychoV()) {
    SV_Target.rgb = ResonanceRenderIntermediatePassDithered(
        resonance_post_process_output, SV_Position.xy);
  }
  return SV_Target;
}