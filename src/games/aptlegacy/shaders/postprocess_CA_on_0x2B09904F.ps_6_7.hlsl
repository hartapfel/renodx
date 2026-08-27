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
  int _143 = asint((User_000.UserConstant_Z_000[7].z));
  bool _144 = ((int)_143 > (int)0);
  float _173;
  float _257;
  float _294;
  float _484;
  float _523;
  float _524;
  float _525;
  float _564;
  float _565;
  float _566;
  float _769;
  float _873;
  float _977;
  float _980;
  float _981;
  float _982;
  float _993;
  float _1118;
  float _1119;
  float _1120;
  float _1167;
  float _1168;
  float _1169;
  float _1183;
  float _1184;
  float _1185;
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
  float4 _527 = t12.SampleLevel(s0, float2(_57, _58), 0.0f);
  float4 _533 = t8.Sample(s8, float2(_59, _60));
  bool _539 = !((PostProcess_000.PostProcessConstant_Z_000[17].z) >= -1.0f);
  float _543 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _533.x;
  float _544 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _533.y;
  float _545 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _533.z;
  float _546 = _543 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
  float _547 = _544 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
  float _548 = _545 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
  if (!_539) {
    float _550 = _546 * _527.x;
    float _551 = _547 * _527.y;
    float _552 = _548 * _527.z;
    _564 = _550;
    _565 = _551;
    _566 = _552;
  } else {
    float _554 = saturate(_546);
    float _555 = saturate(_547);
    float _556 = saturate(_548);
    float _557 = _527.x - _523;
    float _558 = _527.y - _524;
    float _559 = _527.z - _525;
    float _560 = _554 * _557;
    float _561 = _555 * _558;
    float _562 = _556 * _559;
    _564 = _560;
    _565 = _561;
    _566 = _562;
  }
  float _567 = _564 + _523;
  float _568 = _565 + _524;
  float _569 = _566 + _525;
  float4 _573 = t17.Load(int3(0, 0, 0));
  float _581 = (PostProcess_000.PostProcessConstant_Z_000[10].w) * 9.999999747378752e-05f;
  float _582 = (Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[87].y) * 11190.6005859375f;
  float _583 = _573.x * _582;
  float _584 = _583 * _567;
  float _585 = _584 * (PostProcess_000.PostProcessConstant_Z_000[14].x);
  float _586 = _585 * _581;
  float _587 = _583 * _568;
  float _588 = _587 * (PostProcess_000.PostProcessConstant_Z_000[14].y);
  float _589 = _588 * _581;
  float _590 = _583 * _569;
  float _591 = _590 * (PostProcess_000.PostProcessConstant_Z_000[14].z);
  float _592 = _591 * _581;
  float _593 = _586 + 1.0f;
  float _594 = _589 + 1.0f;
  float _595 = _592 + 1.0f;
  float _596 = log2(_593);
  float _597 = log2(_594);
  float _598 = log2(_595);
  float _601 = (PostProcess_000.PostProcessConstant_Z_320[0].x) * 0.07434873282909393f;
  float _602 = _601 * _596;
  float _603 = _601 * _597;
  float _604 = _601 * _598;
  float _606 = _602 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _607 = _603 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _608 = _604 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float4 _611 = t3.Sample(s3, float3(_606, _607, _608));
  float _617 = _611.x * 13.450128555297852f;
  float _618 = _611.y * 13.450128555297852f;
  float _619 = _611.z * 13.450128555297852f;
  float _620 = exp2(_617);
  float _621 = exp2(_618);
  float _622 = exp2(_619);
  float _623 = _620 + -1.0f;
  float _624 = _621 + -1.0f;
  float _625 = _622 + -1.0f;
  float _626 = 0.8936070799827576f / (PostProcess_000.PostProcessConstant_Z_000[10].w);
  float _627 = _626 * _623;
  float _628 = _626 * _624;
  float _629 = _626 * _625;
  float3 apt_scaled_lut_output = APTApplyPostProcessLUT(
      float3(_586 * _626, _589 * _626, _592 * _626),
      float3(_627, _628, _629),
      1.f.xxx);
  _627 = apt_scaled_lut_output.x;
  _628 = apt_scaled_lut_output.y;
  _629 = apt_scaled_lut_output.z;
  bool _632 = ((User_000.UserConstant_Z_000[3].x) > 0.0f);
  if (_632) {
    float _634 = (PostProcess_000.PostProcessConstant_Z_000[10].w) * 1.1190600395202637f;
    float _635 = _627 * _634;
    float _636 = _628 * _634;
    float _637 = _629 * _634;
    float _638 = _635 + 1.0f;
    float _639 = _636 + 1.0f;
    float _640 = _637 + 1.0f;
    float _641 = log2(_638);
    float _642 = log2(_639);
    float _643 = log2(_640);
    float _644 = _641 * 0.07434873282909393f;
    float _645 = _642 * 0.07434873282909393f;
    float _646 = _643 * 0.07434873282909393f;
    int _648 = asint((User_000.UserConstant_Z_000[3].y));
    int _649 = _648 & 1;
    bool _650 = (_649 == 0);
    if (!_650) {
      bool _667 = !(_644 <= (User_000.UserConstant_Z_000[4].x));
      if (!_667) {
        float _669 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _670 = _644 / _669;
        float _671 = _670 * (User_000.UserConstant_Z_000[4].y);
        float _672 = _670 * _670;
        float _673 = _672 * _670;
        float _674 = _673 - _670;
        float _675 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _676 = _669 * _669;
        float _677 = _676 * _675;
        float _678 = _677 * _674;
        float _679 = _678 + _671;
        _769 = _679;
      } else {
        bool _681 = !(_644 <= (User_000.UserConstant_Z_000[4].z));
        if (!_681) {
          float _683 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _684 = max(9.999999974752427e-07f, _683);
          float _685 = _644 - (User_000.UserConstant_Z_000[4].x);
          float _686 = _685 / _684;
          float _687 = 1.0f - _686;
          float _688 = _687 * (User_000.UserConstant_Z_000[4].y);
          float _689 = _686 * (User_000.UserConstant_Z_000[4].w);
          float _690 = _688 + _689;
          float _691 = _687 * _687;
          float _692 = _691 * _687;
          float _693 = _692 - _687;
          float _694 = _693 * (User_000.UserConstant_Z_000[10].x);
          float _695 = _686 * _686;
          float _696 = _695 * _686;
          float _697 = _696 - _686;
          float _698 = _697 * (User_000.UserConstant_Z_000[10].y);
          float _699 = _694 + _698;
          float _700 = _684 * _684;
          float _701 = _700 * 0.1666666716337204f;
          float _702 = _701 * _699;
          float _703 = _690 + _702;
          _769 = _703;
        } else {
          bool _705 = !(_644 <= (User_000.UserConstant_Z_000[9].x));
          if (!_705) {
            float _707 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _708 = max(9.999999974752427e-07f, _707);
            float _709 = _644 - (User_000.UserConstant_Z_000[4].z);
            float _710 = _709 / _708;
            float _711 = 1.0f - _710;
            float _712 = _711 * (User_000.UserConstant_Z_000[4].w);
            float _713 = _710 * (User_000.UserConstant_Z_000[9].y);
            float _714 = _712 + _713;
            float _715 = _711 * _711;
            float _716 = _715 * _711;
            float _717 = _716 - _711;
            float _718 = _717 * (User_000.UserConstant_Z_000[10].y);
            float _719 = _710 * _710;
            float _720 = _719 * _710;
            float _721 = _720 - _710;
            float _722 = _721 * (User_000.UserConstant_Z_000[10].z);
            float _723 = _718 + _722;
            float _724 = _708 * _708;
            float _725 = _724 * 0.1666666716337204f;
            float _726 = _725 * _723;
            float _727 = _714 + _726;
            _769 = _727;
          } else {
            bool _729 = !(_644 <= (User_000.UserConstant_Z_000[9].z));
            if (!_729) {
              float _731 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _732 = max(9.999999974752427e-07f, _731);
              float _733 = _644 - (User_000.UserConstant_Z_000[9].x);
              float _734 = _733 / _732;
              float _735 = 1.0f - _734;
              float _736 = _735 * (User_000.UserConstant_Z_000[9].y);
              float _737 = _734 * (User_000.UserConstant_Z_000[9].w);
              float _738 = _736 + _737;
              float _739 = _735 * _735;
              float _740 = _739 * _735;
              float _741 = _740 - _735;
              float _742 = _741 * (User_000.UserConstant_Z_000[10].z);
              float _743 = _734 * _734;
              float _744 = _743 * _734;
              float _745 = _744 - _734;
              float _746 = _745 * (User_000.UserConstant_Z_000[10].w);
              float _747 = _742 + _746;
              float _748 = _732 * _732;
              float _749 = _748 * 0.1666666716337204f;
              float _750 = _749 * _747;
              float _751 = _738 + _750;
              _769 = _751;
            } else {
              float _753 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _754 = _644 - (User_000.UserConstant_Z_000[9].z);
              float _755 = max(9.999999974752427e-07f, _753);
              float _756 = _754 / _755;
              float _757 = 1.0f - _756;
              float _758 = _757 * (User_000.UserConstant_Z_000[9].w);
              float _759 = _758 + _756;
              float _760 = _757 * _757;
              float _761 = _760 * _757;
              float _762 = _761 - _757;
              float _763 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _764 = _753 * _753;
              float _765 = _764 * _763;
              float _766 = _765 * _762;
              float _767 = _759 + _766;
              _769 = _767;
            }
          }
        }
      }
      float _770 = saturate(_769);
      bool _771 = !(_645 <= (User_000.UserConstant_Z_000[4].x));
      if (!_771) {
        float _773 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _774 = _645 / _773;
        float _775 = _774 * (User_000.UserConstant_Z_000[4].y);
        float _776 = _774 * _774;
        float _777 = _776 * _774;
        float _778 = _777 - _774;
        float _779 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _780 = _773 * _773;
        float _781 = _780 * _779;
        float _782 = _781 * _778;
        float _783 = _782 + _775;
        _873 = _783;
      } else {
        bool _785 = !(_645 <= (User_000.UserConstant_Z_000[4].z));
        if (!_785) {
          float _787 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _788 = max(9.999999974752427e-07f, _787);
          float _789 = _645 - (User_000.UserConstant_Z_000[4].x);
          float _790 = _789 / _788;
          float _791 = 1.0f - _790;
          float _792 = _791 * (User_000.UserConstant_Z_000[4].y);
          float _793 = _790 * (User_000.UserConstant_Z_000[4].w);
          float _794 = _792 + _793;
          float _795 = _791 * _791;
          float _796 = _795 * _791;
          float _797 = _796 - _791;
          float _798 = _797 * (User_000.UserConstant_Z_000[10].x);
          float _799 = _790 * _790;
          float _800 = _799 * _790;
          float _801 = _800 - _790;
          float _802 = _801 * (User_000.UserConstant_Z_000[10].y);
          float _803 = _798 + _802;
          float _804 = _788 * _788;
          float _805 = _804 * 0.1666666716337204f;
          float _806 = _805 * _803;
          float _807 = _794 + _806;
          _873 = _807;
        } else {
          bool _809 = !(_645 <= (User_000.UserConstant_Z_000[9].x));
          if (!_809) {
            float _811 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _812 = max(9.999999974752427e-07f, _811);
            float _813 = _645 - (User_000.UserConstant_Z_000[4].z);
            float _814 = _813 / _812;
            float _815 = 1.0f - _814;
            float _816 = _815 * (User_000.UserConstant_Z_000[4].w);
            float _817 = _814 * (User_000.UserConstant_Z_000[9].y);
            float _818 = _816 + _817;
            float _819 = _815 * _815;
            float _820 = _819 * _815;
            float _821 = _820 - _815;
            float _822 = _821 * (User_000.UserConstant_Z_000[10].y);
            float _823 = _814 * _814;
            float _824 = _823 * _814;
            float _825 = _824 - _814;
            float _826 = _825 * (User_000.UserConstant_Z_000[10].z);
            float _827 = _822 + _826;
            float _828 = _812 * _812;
            float _829 = _828 * 0.1666666716337204f;
            float _830 = _829 * _827;
            float _831 = _818 + _830;
            _873 = _831;
          } else {
            bool _833 = !(_645 <= (User_000.UserConstant_Z_000[9].z));
            if (!_833) {
              float _835 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _836 = max(9.999999974752427e-07f, _835);
              float _837 = _645 - (User_000.UserConstant_Z_000[9].x);
              float _838 = _837 / _836;
              float _839 = 1.0f - _838;
              float _840 = _839 * (User_000.UserConstant_Z_000[9].y);
              float _841 = _838 * (User_000.UserConstant_Z_000[9].w);
              float _842 = _840 + _841;
              float _843 = _839 * _839;
              float _844 = _843 * _839;
              float _845 = _844 - _839;
              float _846 = _845 * (User_000.UserConstant_Z_000[10].z);
              float _847 = _838 * _838;
              float _848 = _847 * _838;
              float _849 = _848 - _838;
              float _850 = _849 * (User_000.UserConstant_Z_000[10].w);
              float _851 = _846 + _850;
              float _852 = _836 * _836;
              float _853 = _852 * 0.1666666716337204f;
              float _854 = _853 * _851;
              float _855 = _842 + _854;
              _873 = _855;
            } else {
              float _857 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _858 = _645 - (User_000.UserConstant_Z_000[9].z);
              float _859 = max(9.999999974752427e-07f, _857);
              float _860 = _858 / _859;
              float _861 = 1.0f - _860;
              float _862 = _861 * (User_000.UserConstant_Z_000[9].w);
              float _863 = _862 + _860;
              float _864 = _861 * _861;
              float _865 = _864 * _861;
              float _866 = _865 - _861;
              float _867 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _868 = _857 * _857;
              float _869 = _868 * _867;
              float _870 = _869 * _866;
              float _871 = _863 + _870;
              _873 = _871;
            }
          }
        }
      }
      float _874 = saturate(_873);
      bool _875 = !(_646 <= (User_000.UserConstant_Z_000[4].x));
      if (!_875) {
        float _877 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _878 = _646 / _877;
        float _879 = _878 * (User_000.UserConstant_Z_000[4].y);
        float _880 = _878 * _878;
        float _881 = _880 * _878;
        float _882 = _881 - _878;
        float _883 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _884 = _877 * _877;
        float _885 = _884 * _883;
        float _886 = _885 * _882;
        float _887 = _886 + _879;
        _977 = _887;
      } else {
        bool _889 = !(_646 <= (User_000.UserConstant_Z_000[4].z));
        if (!_889) {
          float _891 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _892 = max(9.999999974752427e-07f, _891);
          float _893 = _646 - (User_000.UserConstant_Z_000[4].x);
          float _894 = _893 / _892;
          float _895 = 1.0f - _894;
          float _896 = _895 * (User_000.UserConstant_Z_000[4].y);
          float _897 = _894 * (User_000.UserConstant_Z_000[4].w);
          float _898 = _896 + _897;
          float _899 = _895 * _895;
          float _900 = _899 * _895;
          float _901 = _900 - _895;
          float _902 = _901 * (User_000.UserConstant_Z_000[10].x);
          float _903 = _894 * _894;
          float _904 = _903 * _894;
          float _905 = _904 - _894;
          float _906 = _905 * (User_000.UserConstant_Z_000[10].y);
          float _907 = _902 + _906;
          float _908 = _892 * _892;
          float _909 = _908 * 0.1666666716337204f;
          float _910 = _909 * _907;
          float _911 = _898 + _910;
          _977 = _911;
        } else {
          bool _913 = !(_646 <= (User_000.UserConstant_Z_000[9].x));
          if (!_913) {
            float _915 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _916 = max(9.999999974752427e-07f, _915);
            float _917 = _646 - (User_000.UserConstant_Z_000[4].z);
            float _918 = _917 / _916;
            float _919 = 1.0f - _918;
            float _920 = _919 * (User_000.UserConstant_Z_000[4].w);
            float _921 = _918 * (User_000.UserConstant_Z_000[9].y);
            float _922 = _920 + _921;
            float _923 = _919 * _919;
            float _924 = _923 * _919;
            float _925 = _924 - _919;
            float _926 = _925 * (User_000.UserConstant_Z_000[10].y);
            float _927 = _918 * _918;
            float _928 = _927 * _918;
            float _929 = _928 - _918;
            float _930 = _929 * (User_000.UserConstant_Z_000[10].z);
            float _931 = _926 + _930;
            float _932 = _916 * _916;
            float _933 = _932 * 0.1666666716337204f;
            float _934 = _933 * _931;
            float _935 = _922 + _934;
            _977 = _935;
          } else {
            bool _937 = !(_646 <= (User_000.UserConstant_Z_000[9].z));
            if (!_937) {
              float _939 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _940 = max(9.999999974752427e-07f, _939);
              float _941 = _646 - (User_000.UserConstant_Z_000[9].x);
              float _942 = _941 / _940;
              float _943 = 1.0f - _942;
              float _944 = _943 * (User_000.UserConstant_Z_000[9].y);
              float _945 = _942 * (User_000.UserConstant_Z_000[9].w);
              float _946 = _944 + _945;
              float _947 = _943 * _943;
              float _948 = _947 * _943;
              float _949 = _948 - _943;
              float _950 = _949 * (User_000.UserConstant_Z_000[10].z);
              float _951 = _942 * _942;
              float _952 = _951 * _942;
              float _953 = _952 - _942;
              float _954 = _953 * (User_000.UserConstant_Z_000[10].w);
              float _955 = _950 + _954;
              float _956 = _940 * _940;
              float _957 = _956 * 0.1666666716337204f;
              float _958 = _957 * _955;
              float _959 = _946 + _958;
              _977 = _959;
            } else {
              float _961 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _962 = _646 - (User_000.UserConstant_Z_000[9].z);
              float _963 = max(9.999999974752427e-07f, _961);
              float _964 = _962 / _963;
              float _965 = 1.0f - _964;
              float _966 = _965 * (User_000.UserConstant_Z_000[9].w);
              float _967 = _966 + _964;
              float _968 = _965 * _965;
              float _969 = _968 * _965;
              float _970 = _969 - _965;
              float _971 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _972 = _961 * _961;
              float _973 = _972 * _971;
              float _974 = _973 * _970;
              float _975 = _967 + _974;
              _977 = _975;
            }
          }
        }
      }
      float _978 = saturate(_977);
      _980 = _770;
      _981 = _874;
      _982 = _978;
    } else {
      _980 = _644;
      _981 = _645;
      _982 = _646;
    }
    int _983 = _648 & 2;
    bool _984 = (_983 == 0);
    if (!_984) {
      float _986 = sqrt(_980);
      float _987 = sqrt(_981);
      float _988 = sqrt(_982);
      float _989 = dot(float3(_986, _987, _988), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
      float _990 = 1.0f - _989;
      float _991 = saturate(_990);
      _993 = _991;
    } else {
      _993 = 1.0f;
    }
    int _994 = _648 & 8;
    bool _995 = (_994 == 0);
    if (_995) {
      int _997 = _648 & 4;
      bool _998 = (_997 == 0);
      if (!_998) {
        int _1000 = _648 & 16;
        bool _1001 = (_1000 == 0);
        if (!_1001) {
          float _1005 = (User_000.UserConstant_Z_000[5].x) * 0.5f;
          float _1006 = _1005 + 0.5f;
          bool _1007 = (_1006 < 0.5f);
          float _1008 = (User_000.UserConstant_Z_000[5].x) * 5.0f;
          float _1009 = select(_1007, (User_000.UserConstant_Z_000[5].x), _1008);
          bool _1010 = (_981 < _982);
          float _1011 = select(_1010, _982, _981);
          float _1012 = select(_1010, _981, _982);
          bool _1013 = (_980 < _1011);
          float _1014 = select(_1013, _1011, _980);
          float _1015 = select(_1013, _980, _1011);
          float _1016 = min(_1015, _1012);
          float _1017 = _1014 - _1016;
          float _1018 = _1014 + 1.000000013351432e-10f;
          float _1019 = _1017 / _1018;
          float _1021 = _1019 - (User_000.UserConstant_Z_000[5].y);
          float _1022 = saturate(_1021);
          float _1023 = max(_1022, 9.999999974752427e-07f);
          float _1024 = log2(_1023);
          float _1025 = _1024 * _1009;
          float _1026 = exp2(_1025);
          float _1027 = 2.0f - _1026;
          float _1029 = 1.0f - (User_000.UserConstant_Z_000[5].z);
          float _1030 = saturate(_1029);
          float _1031 = max(_1030, _1027);
          float _1032 = dot(float3(_980, _981, _982), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
          float _1033 = _980 - _1032;
          float _1034 = _981 - _1032;
          float _1035 = _982 - _1032;
          float _1036 = _1033 * _1031;
          float _1037 = _1034 * _1031;
          float _1038 = _1035 * _1031;
          float _1039 = _1032 - _980;
          float _1040 = _1039 + _1036;
          float _1041 = _1032 - _981;
          float _1042 = _1041 + _1037;
          float _1043 = _1032 - _982;
          float _1044 = _1043 + _1038;
          float _1045 = _1040 * _993;
          float _1046 = _1042 * _993;
          float _1047 = _1044 * _993;
          float _1048 = _1045 + _980;
          float _1049 = _1046 + _981;
          float _1050 = _1047 + _982;
          _1167 = _1048;
          _1168 = _1049;
          _1169 = _1050;
        } else {
          bool _1052 = (_993 == 0.0f);
          if (!_1052) {
            float _1056 = abs(User_000.UserConstant_Z_000[5].x);
            float _1057 = saturate(_1056);
            uint4 _1059 = 0u; t15.GetDimensions(0u, _1059.x, _1059.y, _1059.w);
            float _1062 = float((uint)_1059.y);
            int _1063 = _648 & 32;
            bool _1064 = (_1063 == 0);
            float _1065 = _1062 + -1.0f;
            if (!_1064) {
              float _1067 = 1.0f / _1065;
              uint _1068 = uint(SV_Position.x);
              uint _1069 = uint(SV_Position.y);
              int _1070 = _1068 & 63;
              int _1071 = _1069 & 63;
              float4 _1073 = t6.Load(int4(_1070, _1071, 0, 0));
              float _1076 = _1073.x + -0.5f;
              float _1077 = _980 * 13.999999046325684f;
              float _1078 = _981 * 13.999999046325684f;
              float _1079 = _982 * 13.999999046325684f;
              float _1080 = saturate(_1077);
              float _1081 = saturate(_1078);
              float _1082 = saturate(_1079);
              float _1083 = _980 + -0.9285714030265808f;
              float _1084 = _981 + -0.9285714030265808f;
              float _1085 = _982 + -0.9285714030265808f;
              float _1086 = _1083 * 13.999999046325684f;
              float _1087 = _1084 * 13.999999046325684f;
              float _1088 = _1085 * 13.999999046325684f;
              float _1089 = saturate(_1086);
              float _1090 = saturate(_1087);
              float _1091 = saturate(_1088);
              float _1092 = 1.0f - _1089;
              float _1093 = 1.0f - _1090;
              float _1094 = 1.0f - _1091;
              float _1095 = min(_1080, _1092);
              float _1096 = min(_1081, _1093);
              float _1097 = min(_1082, _1094);
              float _1098 = _1073.y + -0.5f;
              float _1099 = _1095 * _1098;
              float _1100 = _1096 * _1098;
              float _1101 = _1097 * _1098;
              float _1102 = _1099 + _1076;
              float _1103 = _1100 + _1076;
              float _1104 = _1101 + _1076;
              float _1105 = _1102 * _1067;
              float _1106 = _1103 * _1067;
              float _1107 = _1104 * _1067;
              float _1108 = _1105 + _980;
              float _1109 = _1106 + _981;
              float _1110 = _1107 + _982;
              float _1111 = saturate(_1108);
              float _1112 = saturate(_1109);
              float _1113 = saturate(_1110);
              float _1114 = saturate(_1111);
              float _1115 = saturate(_1112);
              float _1116 = saturate(_1113);
              _1118 = _1114;
              _1119 = _1115;
              _1120 = _1116;
            } else {
              _1118 = _980;
              _1119 = _981;
              _1120 = _982;
            }
            float _1121 = float((uint)_1059.x);
            float _1122 = _1065 / _1121;
            float _1123 = _1122 * _1118;
            float _1124 = 0.5f / _1121;
            float _1125 = _1123 + _1124;
            float _1126 = _1065 / _1062;
            float _1127 = _1126 * _1119;
            float _1128 = 0.5f / _1062;
            float _1129 = _1127 + _1128;
            float _1130 = _1120 * _1065;
            float _1131 = floor(_1130);
            float _1132 = frac(_1130);
            float _1133 = _1131 / _1062;
            float _1134 = _1133 + _1125;
            float _1135 = _1131 + 1.0f;
            float _1136 = _1135 / _1062;
            float _1137 = _1136 + _1125;
            float4 _1139 = t15.Sample(s0, float2(_1134, _1129));
            float4 _1143 = t15.Sample(s0, float2(_1137, _1129));
            float _1147 = _1143.x - _1139.x;
            float _1148 = _1143.y - _1139.y;
            float _1149 = _1143.z - _1139.z;
            float _1150 = _1147 * _1132;
            float _1151 = _1148 * _1132;
            float _1152 = _1149 * _1132;
            float _1153 = _1057 * _993;
            float _1154 = _1139.x - _980;
            float _1155 = _1154 + _1150;
            float _1156 = _1139.y - _981;
            float _1157 = _1156 + _1151;
            float _1158 = _1139.z - _982;
            float _1159 = _1158 + _1152;
            float _1160 = _1155 * _1153;
            float _1161 = _1157 * _1153;
            float _1162 = _1159 * _1153;
            float _1163 = _1160 + _980;
            float _1164 = _1161 + _981;
            float _1165 = _1162 + _982;
            _1167 = _1163;
            _1168 = _1164;
            _1169 = _1165;
          } else {
            _1167 = _980;
            _1168 = _981;
            _1169 = _982;
          }
        }
      } else {
        _1167 = _980;
        _1168 = _981;
        _1169 = _982;
      }
    } else {
      _1167 = _993;
      _1168 = _993;
      _1169 = _993;
    }
    float _1170 = _1167 * 13.450128555297852f;
    float _1171 = _1168 * 13.450128555297852f;
    float _1172 = _1169 * 13.450128555297852f;
    float _1173 = exp2(_1170);
    float _1174 = exp2(_1171);
    float _1175 = exp2(_1172);
    float _1176 = _1173 + -1.0f;
    float _1177 = _1174 + -1.0f;
    float _1178 = _1175 + -1.0f;
    float _1179 = _1176 * _626;
    float _1180 = _1177 * _626;
    float _1181 = _1178 * _626;
    _1183 = _1179;
    _1184 = _1180;
    _1185 = _1181;
  } else {
    _1183 = _627;
    _1184 = _628;
    _1185 = _629;
  }
  float3 apt_perceptual_film_grain = APTApplyPerceptualFilmGrain(
      float3((User_000.UserConstant_Z_000[8].x) * _1183, (User_000.UserConstant_Z_000[8].y) * _1184, (User_000.UserConstant_Z_000[8].z) * _1185),
      SV_Position.xy);
  float _1192 = apt_perceptual_film_grain.x;
  float _1193 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 2.0f;
  float _1194 = log2(_1192);
  float _1195 = _1193 * _1194;
  float _1196 = exp2(_1195);
  float _1197 = _1196 + -1.0f;
  float _1198 = _1192 + -1.0f;
  float _1199 = _1197 / _1198;
  bool _1200 = !(_1192 == 1.0f);
  float _1201 = _1199 + -1.0f;
  float _1202 = _1201 / _1199;
  float _1203 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _1204 = _1203 / _1193;
  float _1205 = select(_1200, _1202, _1204);
  float _1206 = apt_perceptual_film_grain.y;
  float _1207 = log2(_1206);
  float _1208 = _1207 * _1193;
  float _1209 = exp2(_1208);
  float _1210 = _1209 + -1.0f;
  float _1211 = _1206 + -1.0f;
  float _1212 = _1210 / _1211;
  bool _1213 = !(_1206 == 1.0f);
  float _1214 = _1212 + -1.0f;
  float _1215 = _1214 / _1212;
  float _1216 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _1217 = _1216 / _1193;
  float _1218 = select(_1213, _1215, _1217);
  float _1219 = apt_perceptual_film_grain.z;
  float _1220 = log2(_1219);
  float _1221 = _1220 * _1193;
  float _1222 = exp2(_1221);
  float _1223 = _1222 + -1.0f;
  float _1224 = _1219 + -1.0f;
  float _1225 = _1223 / _1224;
  bool _1226 = !(_1219 == 1.0f);
  float _1227 = _1225 + -1.0f;
  float _1228 = _1227 / _1225;
  float _1229 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _1230 = _1229 / _1193;
  float _1231 = select(_1226, _1228, _1230);
  float3 apt_post_process_output = APTApplyPostProcessToneMap(
      float3(_1192, _1206, _1219),
      float3(_1205, _1218, _1231),
      true);
  float _1232 = apt_post_process_output.x;
  float _1233 = apt_post_process_output.y;
  float _1234 = apt_post_process_output.z;
  float _1235 = log2(_1232);
  float _1236 = log2(_1233);
  float _1237 = log2(_1234);
  float _1238 = _1235 * 0.4166666567325592f;
  float _1239 = _1236 * 0.4166666567325592f;
  float _1240 = _1237 * 0.4166666567325592f;
  float _1241 = exp2(_1238);
  float _1242 = exp2(_1239);
  float _1243 = exp2(_1240);
  float _1244 = _1241 * 1.0549999475479126f;
  float _1245 = _1242 * 1.0549999475479126f;
  float _1246 = _1243 * 1.0549999475479126f;
  float _1247 = _1244 + -0.054999999701976776f;
  float _1248 = _1245 + -0.054999999701976776f;
  float _1249 = _1246 + -0.054999999701976776f;
  float _1250 = _1232 * 12.920000076293945f;
  float _1251 = _1233 * 12.920000076293945f;
  float _1252 = _1234 * 12.920000076293945f;
  bool _1253 = (_1232 <= 0.0031308000907301903f);
  bool _1254 = (_1233 <= 0.0031308000907301903f);
  bool _1255 = (_1234 <= 0.0031308000907301903f);
  float _1256 = select(_1253, _1250, _1247);
  float _1257 = select(_1254, _1251, _1248);
  float _1258 = select(_1255, _1252, _1249);
  int _1261 = asint((Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[1].w));
  uint _1262 = uint(SV_Position.x);
  uint _1263 = uint(SV_Position.y);
  int _1264 = _1262 & 63;
  int _1265 = _1263 & 63;
  float4 _1267 = t1.Load(int4(_1264, _1265, _1261, 0));
  float _1269 = _1267.x + -0.5f;
  float _1270 = _1269 * 0.003921568859368563f;
  float _1271 = _1270 + _1256;
  float _1272 = _1270 + _1257;
  float _1273 = _1270 + _1258;
  float _1274 = saturate(_1271);
  float _1275 = saturate(_1272);
  float _1276 = saturate(_1273);
  SV_Target.x = _1274;
  SV_Target.y = _1275;
  SV_Target.z = _1276;
  SV_Target.w = _135.w;
  return SV_Target;
}
