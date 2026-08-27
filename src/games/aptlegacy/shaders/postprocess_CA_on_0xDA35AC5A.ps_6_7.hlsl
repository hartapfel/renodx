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
  float _804;
  float _908;
  float _1012;
  float _1015;
  float _1016;
  float _1017;
  float _1028;
  float _1153;
  float _1154;
  float _1155;
  float _1202;
  float _1203;
  float _1204;
  float _1218;
  float _1219;
  float _1220;
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
  float _579 = _573.x * (Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[87].y);
  float _580 = _579 * _567;
  float _581 = _580 * (PostProcess_000.PostProcessConstant_Z_000[14].x);
  float _582 = _579 * _568;
  float _583 = _582 * (PostProcess_000.PostProcessConstant_Z_000[14].y);
  float _584 = _579 * _569;
  float _585 = _584 * (PostProcess_000.PostProcessConstant_Z_000[14].z);
  float _590 = _57 * 2.0f;
  float _591 = _58 * 2.0f;
  float _592 = _590 + -1.0f;
  float _593 = _591 + -1.0f;
  float _596 = (PostProcess_000.PostProcessConstant_Z_000[13].w) * _593;
  float _597 = _592 * _592;
  float _598 = _596 * _596;
  float _599 = _598 + _597;
  float _600 = sqrt(_599);
  float _602 = (PostProcess_000.PostProcessConstant_Z_000[13].x) * _600;
  float _604 = _602 + (PostProcess_000.PostProcessConstant_Z_000[13].y);
  float _605 = saturate(_604);
  float _607 = log2(_605);
  float _608 = _607 * (PostProcess_000.PostProcessConstant_Z_000[13].z);
  float _609 = exp2(_608);
  float _610 = _581 * (PostProcess_000.PostProcessConstant_Z_000[12].x);
  float _611 = _583 * (PostProcess_000.PostProcessConstant_Z_000[12].y);
  float _612 = _585 * (PostProcess_000.PostProcessConstant_Z_000[12].z);
  float _613 = _610 - _581;
  float _614 = _611 - _583;
  float _615 = _612 - _585;
  float _616 = _609 * _613;
  float _617 = _609 * _614;
  float _618 = _609 * _615;
  float _619 = _616 + _581;
  float _620 = _617 + _583;
  float _621 = _618 + _585;
  float _624 = (PostProcess_000.PostProcessConstant_Z_000[10].w) * 1.1190600395202637f;
  float _625 = _624 * _619;
  float _626 = _624 * _620;
  float _627 = _624 * _621;
  float _628 = _625 + 1.0f;
  float _629 = _626 + 1.0f;
  float _630 = _627 + 1.0f;
  float _631 = log2(_628);
  float _632 = log2(_629);
  float _633 = log2(_630);
  float _636 = (PostProcess_000.PostProcessConstant_Z_320[0].x) * 0.07434873282909393f;
  float _637 = _636 * _631;
  float _638 = _636 * _632;
  float _639 = _636 * _633;
  float _641 = _637 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _642 = _638 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _643 = _639 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float4 _646 = t3.Sample(s3, float3(_641, _642, _643));
  float _652 = _646.x * 13.450128555297852f;
  float _653 = _646.y * 13.450128555297852f;
  float _654 = _646.z * 13.450128555297852f;
  float _655 = exp2(_652);
  float _656 = exp2(_653);
  float _657 = exp2(_654);
  float _658 = _655 + -1.0f;
  float _659 = _656 + -1.0f;
  float _660 = _657 + -1.0f;
  float _661 = 0.8936070799827576f / (PostProcess_000.PostProcessConstant_Z_000[10].w);
  float _662 = _661 * _658;
  float _663 = _661 * _659;
  float _664 = _661 * _660;
  float3 apt_scaled_lut_output = APTApplyPostProcessLUT(
      float3(_625 * _661, _626 * _661, _627 * _661),
      float3(_662, _663, _664),
      1.f.xxx);
  _662 = apt_scaled_lut_output.x;
  _663 = apt_scaled_lut_output.y;
  _664 = apt_scaled_lut_output.z;
  bool _667 = ((User_000.UserConstant_Z_000[3].x) > 0.0f) && !APTIsPsychoV();
  if (_667) {
    float _669 = (PostProcess_000.PostProcessConstant_Z_000[10].w) * 1.1190600395202637f;
    float _670 = _662 * _669;
    float _671 = _663 * _669;
    float _672 = _664 * _669;
    float _673 = _670 + 1.0f;
    float _674 = _671 + 1.0f;
    float _675 = _672 + 1.0f;
    float _676 = log2(_673);
    float _677 = log2(_674);
    float _678 = log2(_675);
    float _679 = _676 * 0.07434873282909393f;
    float _680 = _677 * 0.07434873282909393f;
    float _681 = _678 * 0.07434873282909393f;
    int _683 = asint((User_000.UserConstant_Z_000[3].y));
    int _684 = _683 & 1;
    bool _685 = (_684 == 0);
    if (!_685) {
      bool _702 = !(_679 <= (User_000.UserConstant_Z_000[4].x));
      if (!_702) {
        float _704 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _705 = _679 / _704;
        float _706 = _705 * (User_000.UserConstant_Z_000[4].y);
        float _707 = _705 * _705;
        float _708 = _707 * _705;
        float _709 = _708 - _705;
        float _710 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _711 = _704 * _704;
        float _712 = _711 * _710;
        float _713 = _712 * _709;
        float _714 = _713 + _706;
        _804 = _714;
      } else {
        bool _716 = !(_679 <= (User_000.UserConstant_Z_000[4].z));
        if (!_716) {
          float _718 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _719 = max(9.999999974752427e-07f, _718);
          float _720 = _679 - (User_000.UserConstant_Z_000[4].x);
          float _721 = _720 / _719;
          float _722 = 1.0f - _721;
          float _723 = _722 * (User_000.UserConstant_Z_000[4].y);
          float _724 = _721 * (User_000.UserConstant_Z_000[4].w);
          float _725 = _723 + _724;
          float _726 = _722 * _722;
          float _727 = _726 * _722;
          float _728 = _727 - _722;
          float _729 = _728 * (User_000.UserConstant_Z_000[10].x);
          float _730 = _721 * _721;
          float _731 = _730 * _721;
          float _732 = _731 - _721;
          float _733 = _732 * (User_000.UserConstant_Z_000[10].y);
          float _734 = _729 + _733;
          float _735 = _719 * _719;
          float _736 = _735 * 0.1666666716337204f;
          float _737 = _736 * _734;
          float _738 = _725 + _737;
          _804 = _738;
        } else {
          bool _740 = !(_679 <= (User_000.UserConstant_Z_000[9].x));
          if (!_740) {
            float _742 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _743 = max(9.999999974752427e-07f, _742);
            float _744 = _679 - (User_000.UserConstant_Z_000[4].z);
            float _745 = _744 / _743;
            float _746 = 1.0f - _745;
            float _747 = _746 * (User_000.UserConstant_Z_000[4].w);
            float _748 = _745 * (User_000.UserConstant_Z_000[9].y);
            float _749 = _747 + _748;
            float _750 = _746 * _746;
            float _751 = _750 * _746;
            float _752 = _751 - _746;
            float _753 = _752 * (User_000.UserConstant_Z_000[10].y);
            float _754 = _745 * _745;
            float _755 = _754 * _745;
            float _756 = _755 - _745;
            float _757 = _756 * (User_000.UserConstant_Z_000[10].z);
            float _758 = _753 + _757;
            float _759 = _743 * _743;
            float _760 = _759 * 0.1666666716337204f;
            float _761 = _760 * _758;
            float _762 = _749 + _761;
            _804 = _762;
          } else {
            bool _764 = !(_679 <= (User_000.UserConstant_Z_000[9].z));
            if (!_764) {
              float _766 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _767 = max(9.999999974752427e-07f, _766);
              float _768 = _679 - (User_000.UserConstant_Z_000[9].x);
              float _769 = _768 / _767;
              float _770 = 1.0f - _769;
              float _771 = _770 * (User_000.UserConstant_Z_000[9].y);
              float _772 = _769 * (User_000.UserConstant_Z_000[9].w);
              float _773 = _771 + _772;
              float _774 = _770 * _770;
              float _775 = _774 * _770;
              float _776 = _775 - _770;
              float _777 = _776 * (User_000.UserConstant_Z_000[10].z);
              float _778 = _769 * _769;
              float _779 = _778 * _769;
              float _780 = _779 - _769;
              float _781 = _780 * (User_000.UserConstant_Z_000[10].w);
              float _782 = _777 + _781;
              float _783 = _767 * _767;
              float _784 = _783 * 0.1666666716337204f;
              float _785 = _784 * _782;
              float _786 = _773 + _785;
              _804 = _786;
            } else {
              float _788 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _789 = _679 - (User_000.UserConstant_Z_000[9].z);
              float _790 = max(9.999999974752427e-07f, _788);
              float _791 = _789 / _790;
              float _792 = 1.0f - _791;
              float _793 = _792 * (User_000.UserConstant_Z_000[9].w);
              float _794 = _793 + _791;
              float _795 = _792 * _792;
              float _796 = _795 * _792;
              float _797 = _796 - _792;
              float _798 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _799 = _788 * _788;
              float _800 = _799 * _798;
              float _801 = _800 * _797;
              float _802 = _794 + _801;
              _804 = _802;
            }
          }
        }
      }
      float _805 = saturate(_804);
      bool _806 = !(_680 <= (User_000.UserConstant_Z_000[4].x));
      if (!_806) {
        float _808 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _809 = _680 / _808;
        float _810 = _809 * (User_000.UserConstant_Z_000[4].y);
        float _811 = _809 * _809;
        float _812 = _811 * _809;
        float _813 = _812 - _809;
        float _814 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _815 = _808 * _808;
        float _816 = _815 * _814;
        float _817 = _816 * _813;
        float _818 = _817 + _810;
        _908 = _818;
      } else {
        bool _820 = !(_680 <= (User_000.UserConstant_Z_000[4].z));
        if (!_820) {
          float _822 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _823 = max(9.999999974752427e-07f, _822);
          float _824 = _680 - (User_000.UserConstant_Z_000[4].x);
          float _825 = _824 / _823;
          float _826 = 1.0f - _825;
          float _827 = _826 * (User_000.UserConstant_Z_000[4].y);
          float _828 = _825 * (User_000.UserConstant_Z_000[4].w);
          float _829 = _827 + _828;
          float _830 = _826 * _826;
          float _831 = _830 * _826;
          float _832 = _831 - _826;
          float _833 = _832 * (User_000.UserConstant_Z_000[10].x);
          float _834 = _825 * _825;
          float _835 = _834 * _825;
          float _836 = _835 - _825;
          float _837 = _836 * (User_000.UserConstant_Z_000[10].y);
          float _838 = _833 + _837;
          float _839 = _823 * _823;
          float _840 = _839 * 0.1666666716337204f;
          float _841 = _840 * _838;
          float _842 = _829 + _841;
          _908 = _842;
        } else {
          bool _844 = !(_680 <= (User_000.UserConstant_Z_000[9].x));
          if (!_844) {
            float _846 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _847 = max(9.999999974752427e-07f, _846);
            float _848 = _680 - (User_000.UserConstant_Z_000[4].z);
            float _849 = _848 / _847;
            float _850 = 1.0f - _849;
            float _851 = _850 * (User_000.UserConstant_Z_000[4].w);
            float _852 = _849 * (User_000.UserConstant_Z_000[9].y);
            float _853 = _851 + _852;
            float _854 = _850 * _850;
            float _855 = _854 * _850;
            float _856 = _855 - _850;
            float _857 = _856 * (User_000.UserConstant_Z_000[10].y);
            float _858 = _849 * _849;
            float _859 = _858 * _849;
            float _860 = _859 - _849;
            float _861 = _860 * (User_000.UserConstant_Z_000[10].z);
            float _862 = _857 + _861;
            float _863 = _847 * _847;
            float _864 = _863 * 0.1666666716337204f;
            float _865 = _864 * _862;
            float _866 = _853 + _865;
            _908 = _866;
          } else {
            bool _868 = !(_680 <= (User_000.UserConstant_Z_000[9].z));
            if (!_868) {
              float _870 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _871 = max(9.999999974752427e-07f, _870);
              float _872 = _680 - (User_000.UserConstant_Z_000[9].x);
              float _873 = _872 / _871;
              float _874 = 1.0f - _873;
              float _875 = _874 * (User_000.UserConstant_Z_000[9].y);
              float _876 = _873 * (User_000.UserConstant_Z_000[9].w);
              float _877 = _875 + _876;
              float _878 = _874 * _874;
              float _879 = _878 * _874;
              float _880 = _879 - _874;
              float _881 = _880 * (User_000.UserConstant_Z_000[10].z);
              float _882 = _873 * _873;
              float _883 = _882 * _873;
              float _884 = _883 - _873;
              float _885 = _884 * (User_000.UserConstant_Z_000[10].w);
              float _886 = _881 + _885;
              float _887 = _871 * _871;
              float _888 = _887 * 0.1666666716337204f;
              float _889 = _888 * _886;
              float _890 = _877 + _889;
              _908 = _890;
            } else {
              float _892 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _893 = _680 - (User_000.UserConstant_Z_000[9].z);
              float _894 = max(9.999999974752427e-07f, _892);
              float _895 = _893 / _894;
              float _896 = 1.0f - _895;
              float _897 = _896 * (User_000.UserConstant_Z_000[9].w);
              float _898 = _897 + _895;
              float _899 = _896 * _896;
              float _900 = _899 * _896;
              float _901 = _900 - _896;
              float _902 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _903 = _892 * _892;
              float _904 = _903 * _902;
              float _905 = _904 * _901;
              float _906 = _898 + _905;
              _908 = _906;
            }
          }
        }
      }
      float _909 = saturate(_908);
      bool _910 = !(_681 <= (User_000.UserConstant_Z_000[4].x));
      if (!_910) {
        float _912 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _913 = _681 / _912;
        float _914 = _913 * (User_000.UserConstant_Z_000[4].y);
        float _915 = _913 * _913;
        float _916 = _915 * _913;
        float _917 = _916 - _913;
        float _918 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _919 = _912 * _912;
        float _920 = _919 * _918;
        float _921 = _920 * _917;
        float _922 = _921 + _914;
        _1012 = _922;
      } else {
        bool _924 = !(_681 <= (User_000.UserConstant_Z_000[4].z));
        if (!_924) {
          float _926 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _927 = max(9.999999974752427e-07f, _926);
          float _928 = _681 - (User_000.UserConstant_Z_000[4].x);
          float _929 = _928 / _927;
          float _930 = 1.0f - _929;
          float _931 = _930 * (User_000.UserConstant_Z_000[4].y);
          float _932 = _929 * (User_000.UserConstant_Z_000[4].w);
          float _933 = _931 + _932;
          float _934 = _930 * _930;
          float _935 = _934 * _930;
          float _936 = _935 - _930;
          float _937 = _936 * (User_000.UserConstant_Z_000[10].x);
          float _938 = _929 * _929;
          float _939 = _938 * _929;
          float _940 = _939 - _929;
          float _941 = _940 * (User_000.UserConstant_Z_000[10].y);
          float _942 = _937 + _941;
          float _943 = _927 * _927;
          float _944 = _943 * 0.1666666716337204f;
          float _945 = _944 * _942;
          float _946 = _933 + _945;
          _1012 = _946;
        } else {
          bool _948 = !(_681 <= (User_000.UserConstant_Z_000[9].x));
          if (!_948) {
            float _950 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _951 = max(9.999999974752427e-07f, _950);
            float _952 = _681 - (User_000.UserConstant_Z_000[4].z);
            float _953 = _952 / _951;
            float _954 = 1.0f - _953;
            float _955 = _954 * (User_000.UserConstant_Z_000[4].w);
            float _956 = _953 * (User_000.UserConstant_Z_000[9].y);
            float _957 = _955 + _956;
            float _958 = _954 * _954;
            float _959 = _958 * _954;
            float _960 = _959 - _954;
            float _961 = _960 * (User_000.UserConstant_Z_000[10].y);
            float _962 = _953 * _953;
            float _963 = _962 * _953;
            float _964 = _963 - _953;
            float _965 = _964 * (User_000.UserConstant_Z_000[10].z);
            float _966 = _961 + _965;
            float _967 = _951 * _951;
            float _968 = _967 * 0.1666666716337204f;
            float _969 = _968 * _966;
            float _970 = _957 + _969;
            _1012 = _970;
          } else {
            bool _972 = !(_681 <= (User_000.UserConstant_Z_000[9].z));
            if (!_972) {
              float _974 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _975 = max(9.999999974752427e-07f, _974);
              float _976 = _681 - (User_000.UserConstant_Z_000[9].x);
              float _977 = _976 / _975;
              float _978 = 1.0f - _977;
              float _979 = _978 * (User_000.UserConstant_Z_000[9].y);
              float _980 = _977 * (User_000.UserConstant_Z_000[9].w);
              float _981 = _979 + _980;
              float _982 = _978 * _978;
              float _983 = _982 * _978;
              float _984 = _983 - _978;
              float _985 = _984 * (User_000.UserConstant_Z_000[10].z);
              float _986 = _977 * _977;
              float _987 = _986 * _977;
              float _988 = _987 - _977;
              float _989 = _988 * (User_000.UserConstant_Z_000[10].w);
              float _990 = _985 + _989;
              float _991 = _975 * _975;
              float _992 = _991 * 0.1666666716337204f;
              float _993 = _992 * _990;
              float _994 = _981 + _993;
              _1012 = _994;
            } else {
              float _996 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _997 = _681 - (User_000.UserConstant_Z_000[9].z);
              float _998 = max(9.999999974752427e-07f, _996);
              float _999 = _997 / _998;
              float _1000 = 1.0f - _999;
              float _1001 = _1000 * (User_000.UserConstant_Z_000[9].w);
              float _1002 = _1001 + _999;
              float _1003 = _1000 * _1000;
              float _1004 = _1003 * _1000;
              float _1005 = _1004 - _1000;
              float _1006 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _1007 = _996 * _996;
              float _1008 = _1007 * _1006;
              float _1009 = _1008 * _1005;
              float _1010 = _1002 + _1009;
              _1012 = _1010;
            }
          }
        }
      }
      float _1013 = saturate(_1012);
      _1015 = _805;
      _1016 = _909;
      _1017 = _1013;
    } else {
      _1015 = _679;
      _1016 = _680;
      _1017 = _681;
    }
    int _1018 = _683 & 2;
    bool _1019 = (_1018 == 0);
    if (!_1019) {
      float _1021 = sqrt(_1015);
      float _1022 = sqrt(_1016);
      float _1023 = sqrt(_1017);
      float _1024 = dot(float3(_1021, _1022, _1023), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
      float _1025 = 1.0f - _1024;
      float _1026 = saturate(_1025);
      _1028 = _1026;
    } else {
      _1028 = 1.0f;
    }
    int _1029 = _683 & 8;
    bool _1030 = (_1029 == 0);
    if (_1030) {
      int _1032 = _683 & 4;
      bool _1033 = (_1032 == 0);
      if (!_1033) {
        int _1035 = _683 & 16;
        bool _1036 = (_1035 == 0);
        if (!_1036) {
          float _1040 = (User_000.UserConstant_Z_000[5].x) * 0.5f;
          float _1041 = _1040 + 0.5f;
          bool _1042 = (_1041 < 0.5f);
          float _1043 = (User_000.UserConstant_Z_000[5].x) * 5.0f;
          float _1044 = select(_1042, (User_000.UserConstant_Z_000[5].x), _1043);
          bool _1045 = (_1016 < _1017);
          float _1046 = select(_1045, _1017, _1016);
          float _1047 = select(_1045, _1016, _1017);
          bool _1048 = (_1015 < _1046);
          float _1049 = select(_1048, _1046, _1015);
          float _1050 = select(_1048, _1015, _1046);
          float _1051 = min(_1050, _1047);
          float _1052 = _1049 - _1051;
          float _1053 = _1049 + 1.000000013351432e-10f;
          float _1054 = _1052 / _1053;
          float _1056 = _1054 - (User_000.UserConstant_Z_000[5].y);
          float _1057 = saturate(_1056);
          float _1058 = max(_1057, 9.999999974752427e-07f);
          float _1059 = log2(_1058);
          float _1060 = _1059 * _1044;
          float _1061 = exp2(_1060);
          float _1062 = 2.0f - _1061;
          float _1064 = 1.0f - (User_000.UserConstant_Z_000[5].z);
          float _1065 = saturate(_1064);
          float _1066 = max(_1065, _1062);
          float _1067 = dot(float3(_1015, _1016, _1017), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
          float _1068 = _1015 - _1067;
          float _1069 = _1016 - _1067;
          float _1070 = _1017 - _1067;
          float _1071 = _1068 * _1066;
          float _1072 = _1069 * _1066;
          float _1073 = _1070 * _1066;
          float _1074 = _1067 - _1015;
          float _1075 = _1074 + _1071;
          float _1076 = _1067 - _1016;
          float _1077 = _1076 + _1072;
          float _1078 = _1067 - _1017;
          float _1079 = _1078 + _1073;
          float _1080 = _1075 * _1028;
          float _1081 = _1077 * _1028;
          float _1082 = _1079 * _1028;
          float _1083 = _1080 + _1015;
          float _1084 = _1081 + _1016;
          float _1085 = _1082 + _1017;
          _1202 = _1083;
          _1203 = _1084;
          _1204 = _1085;
        } else {
          bool _1087 = (_1028 == 0.0f);
          if (!_1087) {
            float _1091 = abs(User_000.UserConstant_Z_000[5].x);
            float _1092 = saturate(_1091);
            uint4 _1094 = 0u; t15.GetDimensions(0u, _1094.x, _1094.y, _1094.w);
            float _1097 = float((uint)_1094.y);
            int _1098 = _683 & 32;
            bool _1099 = (_1098 == 0);
            float _1100 = _1097 + -1.0f;
            if (!_1099) {
              float _1102 = 1.0f / _1100;
              uint _1103 = uint(SV_Position.x);
              uint _1104 = uint(SV_Position.y);
              int _1105 = _1103 & 63;
              int _1106 = _1104 & 63;
              float4 _1108 = t6.Load(int4(_1105, _1106, 0, 0));
              float _1111 = _1108.x + -0.5f;
              float _1112 = _1015 * 13.999999046325684f;
              float _1113 = _1016 * 13.999999046325684f;
              float _1114 = _1017 * 13.999999046325684f;
              float _1115 = saturate(_1112);
              float _1116 = saturate(_1113);
              float _1117 = saturate(_1114);
              float _1118 = _1015 + -0.9285714030265808f;
              float _1119 = _1016 + -0.9285714030265808f;
              float _1120 = _1017 + -0.9285714030265808f;
              float _1121 = _1118 * 13.999999046325684f;
              float _1122 = _1119 * 13.999999046325684f;
              float _1123 = _1120 * 13.999999046325684f;
              float _1124 = saturate(_1121);
              float _1125 = saturate(_1122);
              float _1126 = saturate(_1123);
              float _1127 = 1.0f - _1124;
              float _1128 = 1.0f - _1125;
              float _1129 = 1.0f - _1126;
              float _1130 = min(_1115, _1127);
              float _1131 = min(_1116, _1128);
              float _1132 = min(_1117, _1129);
              float _1133 = _1108.y + -0.5f;
              float _1134 = _1130 * _1133;
              float _1135 = _1131 * _1133;
              float _1136 = _1132 * _1133;
              float _1137 = _1134 + _1111;
              float _1138 = _1135 + _1111;
              float _1139 = _1136 + _1111;
              float _1140 = _1137 * _1102;
              float _1141 = _1138 * _1102;
              float _1142 = _1139 * _1102;
              float _1143 = _1140 + _1015;
              float _1144 = _1141 + _1016;
              float _1145 = _1142 + _1017;
              float _1146 = saturate(_1143);
              float _1147 = saturate(_1144);
              float _1148 = saturate(_1145);
              float _1149 = saturate(_1146);
              float _1150 = saturate(_1147);
              float _1151 = saturate(_1148);
              _1153 = _1149;
              _1154 = _1150;
              _1155 = _1151;
            } else {
              _1153 = _1015;
              _1154 = _1016;
              _1155 = _1017;
            }
            float _1156 = float((uint)_1094.x);
            float _1157 = _1100 / _1156;
            float _1158 = _1157 * _1153;
            float _1159 = 0.5f / _1156;
            float _1160 = _1158 + _1159;
            float _1161 = _1100 / _1097;
            float _1162 = _1161 * _1154;
            float _1163 = 0.5f / _1097;
            float _1164 = _1162 + _1163;
            float _1165 = _1155 * _1100;
            float _1166 = floor(_1165);
            float _1167 = frac(_1165);
            float _1168 = _1166 / _1097;
            float _1169 = _1168 + _1160;
            float _1170 = _1166 + 1.0f;
            float _1171 = _1170 / _1097;
            float _1172 = _1171 + _1160;
            float4 _1174 = t15.Sample(s0, float2(_1169, _1164));
            float4 _1178 = t15.Sample(s0, float2(_1172, _1164));
            float _1182 = _1178.x - _1174.x;
            float _1183 = _1178.y - _1174.y;
            float _1184 = _1178.z - _1174.z;
            float _1185 = _1182 * _1167;
            float _1186 = _1183 * _1167;
            float _1187 = _1184 * _1167;
            float _1188 = _1092 * _1028;
            float _1189 = _1174.x - _1015;
            float _1190 = _1189 + _1185;
            float _1191 = _1174.y - _1016;
            float _1192 = _1191 + _1186;
            float _1193 = _1174.z - _1017;
            float _1194 = _1193 + _1187;
            float _1195 = _1190 * _1188;
            float _1196 = _1192 * _1188;
            float _1197 = _1194 * _1188;
            float _1198 = _1195 + _1015;
            float _1199 = _1196 + _1016;
            float _1200 = _1197 + _1017;
            _1202 = _1198;
            _1203 = _1199;
            _1204 = _1200;
          } else {
            _1202 = _1015;
            _1203 = _1016;
            _1204 = _1017;
          }
        }
      } else {
        _1202 = _1015;
        _1203 = _1016;
        _1204 = _1017;
      }
    } else {
      _1202 = _1028;
      _1203 = _1028;
      _1204 = _1028;
    }
    float _1205 = _1202 * 13.450128555297852f;
    float _1206 = _1203 * 13.450128555297852f;
    float _1207 = _1204 * 13.450128555297852f;
    float _1208 = exp2(_1205);
    float _1209 = exp2(_1206);
    float _1210 = exp2(_1207);
    float _1211 = _1208 + -1.0f;
    float _1212 = _1209 + -1.0f;
    float _1213 = _1210 + -1.0f;
    float _1214 = _1211 * _661;
    float _1215 = _1212 * _661;
    float _1216 = _1213 * _661;
    _1218 = _1214;
    _1219 = _1215;
    _1220 = _1216;
  } else {
    _1218 = _662;
    _1219 = _663;
    _1220 = _664;
  }
  float3 apt_perceptual_film_grain = APTApplyPerceptualFilmGrain(
      float3((User_000.UserConstant_Z_000[8].x) * _1218, (User_000.UserConstant_Z_000[8].y) * _1219, (User_000.UserConstant_Z_000[8].z) * _1220),
      SV_Position.xy);
  float _1227 = apt_perceptual_film_grain.x;
  float _1228 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 2.0f;
  float _1229 = log2(_1227);
  float _1230 = _1228 * _1229;
  float _1231 = exp2(_1230);
  float _1232 = _1231 + -1.0f;
  float _1233 = _1227 + -1.0f;
  float _1234 = _1232 / _1233;
  bool _1235 = !(_1227 == 1.0f);
  float _1236 = _1234 + -1.0f;
  float _1237 = _1236 / _1234;
  float _1238 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _1239 = _1238 / _1228;
  float _1240 = select(_1235, _1237, _1239);
  float _1241 = apt_perceptual_film_grain.y;
  float _1242 = log2(_1241);
  float _1243 = _1242 * _1228;
  float _1244 = exp2(_1243);
  float _1245 = _1244 + -1.0f;
  float _1246 = _1241 + -1.0f;
  float _1247 = _1245 / _1246;
  bool _1248 = !(_1241 == 1.0f);
  float _1249 = _1247 + -1.0f;
  float _1250 = _1249 / _1247;
  float _1251 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _1252 = _1251 / _1228;
  float _1253 = select(_1248, _1250, _1252);
  float _1254 = apt_perceptual_film_grain.z;
  float _1255 = log2(_1254);
  float _1256 = _1255 * _1228;
  float _1257 = exp2(_1256);
  float _1258 = _1257 + -1.0f;
  float _1259 = _1254 + -1.0f;
  float _1260 = _1258 / _1259;
  bool _1261 = !(_1254 == 1.0f);
  float _1262 = _1260 + -1.0f;
  float _1263 = _1262 / _1260;
  float _1264 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _1265 = _1264 / _1228;
  float _1266 = select(_1261, _1263, _1265);
  float3 apt_post_process_output = APTApplyPostProcessToneMap(
      float3(_1227, _1241, _1254),
      float3(_1240, _1253, _1266),
      true);
  float _1267 = apt_post_process_output.x;
  float _1268 = apt_post_process_output.y;
  float _1269 = apt_post_process_output.z;
  float _1270 = log2(_1267);
  float _1271 = log2(_1268);
  float _1272 = log2(_1269);
  float _1273 = _1270 * 0.4166666567325592f;
  float _1274 = _1271 * 0.4166666567325592f;
  float _1275 = _1272 * 0.4166666567325592f;
  float _1276 = exp2(_1273);
  float _1277 = exp2(_1274);
  float _1278 = exp2(_1275);
  float _1279 = _1276 * 1.0549999475479126f;
  float _1280 = _1277 * 1.0549999475479126f;
  float _1281 = _1278 * 1.0549999475479126f;
  float _1282 = _1279 + -0.054999999701976776f;
  float _1283 = _1280 + -0.054999999701976776f;
  float _1284 = _1281 + -0.054999999701976776f;
  float _1285 = _1267 * 12.920000076293945f;
  float _1286 = _1268 * 12.920000076293945f;
  float _1287 = _1269 * 12.920000076293945f;
  bool _1288 = (_1267 <= 0.0031308000907301903f);
  bool _1289 = (_1268 <= 0.0031308000907301903f);
  bool _1290 = (_1269 <= 0.0031308000907301903f);
  float _1291 = select(_1288, _1285, _1282);
  float _1292 = select(_1289, _1286, _1283);
  float _1293 = select(_1290, _1287, _1284);
  int _1296 = asint((Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[1].w));
  uint _1297 = uint(SV_Position.x);
  uint _1298 = uint(SV_Position.y);
  int _1299 = _1297 & 63;
  int _1300 = _1298 & 63;
  float4 _1302 = t1.Load(int4(_1299, _1300, _1296, 0));
  float _1304 = _1302.x + -0.5f;
  float _1305 = _1304 * 0.003921568859368563f;
  float _1306 = _1305 + _1291;
  float _1307 = _1305 + _1292;
  float _1308 = _1305 + _1293;
  float _1309 = saturate(_1306);
  float _1310 = saturate(_1307);
  float _1311 = saturate(_1308);
  SV_Target.x = _1309;
  SV_Target.y = _1310;
  SV_Target.z = _1311;
  SV_Target.w = _135.w;
  return SV_Target;
}
