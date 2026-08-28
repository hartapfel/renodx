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

SamplerState s14 : register(s14);

float4 main(
  linear float4 TEXCOORD : TEXCOORD,
  noperspective float4 SV_Position : SV_Position
) : SV_Target {
  float4 SV_Target;
  float4 _34 = t14.Sample(s14, float2(TEXCOORD.x, TEXCOORD.y));
  float4 _40 = t16.Sample(s0, float2(TEXCOORD.z, TEXCOORD.w));
  float _43 = _40.y * 0.10000000149011612f;
  float _44 = _43 + _34.y;
  float _45 = _40.y * 0.5f;
  float _46 = _45 + _34.z;
  float _47 = exp2(_46);
  float _48 = _47 + -1.0f;
  float _51 = (PostProcess_000.PostProcessConstant_Z_000[11].y) * _48;
  float _52 = _51 + 1.0f;
  float _53 = log2(_52);
  float _54 = _34.x + TEXCOORD.z;
  float _55 = _44 + TEXCOORD.w;
  float _56 = _34.x + TEXCOORD.x;
  float _57 = _44 + TEXCOORD.y;
  float _61 = 0.5f - (PostProcess_000.PostProcessConstant_Z_000[19].x);
  float _62 = 0.5f - (PostProcess_000.PostProcessConstant_Z_000[19].y);
  float _63 = _61 + _54;
  float _64 = _62 + _55;
  float _65 = _63 * 2.0f;
  float _66 = _64 * 2.0f;
  float _67 = _65 + -1.0f;
  float _68 = _66 + -1.0f;
  float _72 = _68 * (Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[51].y);
  float _73 = abs(_67);
  float _74 = abs(_68);
  float _76 = (PostProcess_000.PostProcessConstant_Z_000[19].z) * 2.0f;
  float _77 = _76 + -1.0f;
  float _78 = _73 - _77;
  float _79 = _74 - _77;
  float _80 = saturate(_78);
  float _81 = saturate(_79);
  float _82 = _80 * (Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[51].x);
  float _83 = _82 * _67;
  float _84 = _72 * _81;
  float _85 = _83 * _83;
  float _86 = _84 * _84;
  float _87 = _85 + _86;
  float _88 = sqrt(_87);
  float _91 = _56 + _61;
  float _92 = _57 + _62;
  float _93 = _91 * 2.0f;
  float _94 = _93 + -1.0f;
  float _95 = _92 * 1.125f;
  float _96 = _95 + -0.5625f;
  float _97 = _94 * _94;
  float _98 = _96 * _96;
  float _99 = _97 + _98;
  float _100 = sqrt(_99);
  float _101 = _100 * 0.8715755343437195f;
  float _102 = _101 * _101;
  float _103 = _102 + -0.15000000596046448f;
  float _104 = _103 * 1.8181819915771484f;
  float _105 = saturate(_104);
  float _106 = _105 * 2.0f;
  float _107 = 3.0f - _106;
  float _108 = (PostProcess_000.PostProcessConstant_Z_000[2].w) * _88;
  float _109 = _105 * _105;
  float _110 = _109 * _108;
  float _111 = _110 * _102;
  float _112 = _111 * _107;
  float _114 = (PostProcess_000.PostProcessConstant_Z_000[2].z) * _83;
  float _115 = (PostProcess_000.PostProcessConstant_Z_000[2].z) * _84;
  float _116 = _115 + _55;
  float _117 = _54 - _114;
  float _118 = _40.x * 0.010840999893844128f;
  float _119 = _54 + _118;
  float _120 = _119 + _114;
  float _121 = _55 + _118;
  float _122 = _121 - _115;
  float _123 = _53 + 1.0f;
  float _124 = log2(_123);
  float _125 = max(_112, _124);
  float4 _128 = t0.SampleLevel(s0, float2(_120, _116), _125);
  float4 _130 = t0.SampleLevel(s0, float2(_117, _122), _125);
  float4 _132 = t0.SampleLevel(s0, float2(_54, _55), _125);
  float _135 = max(_128.x, 0.0f);
  float _136 = max(_130.y, 0.0f);
  float _137 = max(_132.z, 0.0f);
  float3 renodx_chromatic_aberration_input = ResonanceSelectChromaticAberrationInput(
      float3(_135, _136, _137),
      max(_132.rgb, 0.f.xxx),
      float2(_54, _55),
      t0,
      s0,
      _125);
  _135 = renodx_chromatic_aberration_input.x;
  _136 = renodx_chromatic_aberration_input.y;
  _137 = renodx_chromatic_aberration_input.z;
  int _140 = asint((User_000.UserConstant_Z_000[7].z));
  bool _141 = ((int)_140 > (int)0);
  float _170;
  float _254;
  float _291;
  float _481;
  float _520;
  float _521;
  float _522;
  float _757;
  float _861;
  float _965;
  float _968;
  float _969;
  float _970;
  float _981;
  float _1106;
  float _1107;
  float _1108;
  float _1155;
  float _1156;
  float _1157;
  float _1171;
  float _1172;
  float _1173;
  [branch]
  if (_141) {
    bool _146 = ((PostProcess_000.PostProcessConstant_Z_000[7].x) > 0.0f);
    if (_146) {
      float _148 = _34.x + TEXCOORD.x;
      float _149 = _44 + TEXCOORD.y;
      float4 _152 = t2.SampleLevel(s2, float2(_148, _149), 0.0f);
      bool _156 = ((PostProcess_000.PostProcessConstant_Z_000[6].y) == 1.0f);
      if (_156) {
        float4 _159 = t7.Load(int3(0, 0, 0));
        float _164 = _159.x - (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
        float _165 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _164;
        _170 = _165;
      } else {
        _170 = (PostProcess_000.PostProcessConstant_Z_000[5].x);
      }
      float _174 = _152.x - (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
      float _175 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _174;
      float _177 = _170 * (PostProcess_000.PostProcessConstant_Z_000[6].w);
      float _178 = _177 + _170;
      float _179 = _170 - _177;
      float _180 = max(_175, _179);
      float _181 = min(_180, _178);
      float _184 = _175 - _181;
      float _185 = (PostProcess_000.PostProcessConstant_Z_000[5].w) * _184;
      float _187 = _181 - (PostProcess_000.PostProcessConstant_Z_000[5].y);
      float _188 = _187 * _175;
      float _189 = _185 / _188;
      float _190 = min(_189, 0.0f);
      float _192 = _177 + 1.0f;
      float _193 = 1.0f / _192;
      float _194 = _190 * (PostProcess_000.PostProcessConstant_Z_000[7].z);
      float _195 = max(0.0f, _189);
      float _198 = (PostProcess_000.PostProcessConstant_Z_000[18].x) * _195;
      float _199 = _198 + _194;
      float _200 = _199 * _193;
      float _201 = max(_200, -1.0f);
      float _202 = min(_201, 1.0f);
      float _203 = max(_202, -0.30000001192092896f);
      float _204 = min(_203, 1.0f);
      float _206 = -0.0f - (PostProcess_000.PostProcessConstant_Z_000[6].x);
      float _207 = _204 * _206;
      float _208 = _148 + -0.5f;
      float _209 = _149 + -0.5f;
      float _210 = _208 * _208;
      float _211 = _209 * _209;
      float _212 = _211 + _210;
      float _213 = sqrt(_212);
      float _214 = log2(_213);
      float _215 = _214 * (PostProcess_000.PostProcessConstant_Z_000[7].y);
      float _216 = exp2(_215);
      float _217 = _216 * (PostProcess_000.PostProcessConstant_Z_000[7].x);
      float _218 = dot(float2(_208, _209), float2(_208, _209));
      float _219 = rsqrt(_218);
      float _220 = _219 * _208;
      float _221 = _219 * _209;
      float _222 = abs(_207);
      float _226 = _217 * _222;
      float _227 = -0.0f - _226;
      float _228 = (User_000.UserConstant_Z_000[2].x) * _220;
      float _229 = _228 * _227;
      float _230 = (User_000.UserConstant_Z_000[2].y) * _221;
      float _231 = _230 * _227;
      float _232 = _222 * _217;
      float _233 = _228 * _232;
      float _234 = _230 * _232;
      float _235 = _233 + _148;
      float _236 = _234 + _149;
      float _237 = _229 + _120;
      float _238 = _231 + _116;
      float4 _239 = t0.SampleLevel(s0, float2(_237, _238), _125);
      float4 _241 = t0.SampleLevel(s0, float2(_235, _236), _125);
      float4 _243 = t2.SampleLevel(s2, float2(_237, _238), 0.0f);
      if (_156) {
        float4 _247 = t7.Load(int3(0, 0, 0));
        float _249 = _247.x - (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
        float _250 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _249;
        _254 = _250;
      } else {
        _254 = (PostProcess_000.PostProcessConstant_Z_000[5].x);
      }
      float _255 = _243.x - (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
      float _256 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _255;
      float _257 = _254 * (PostProcess_000.PostProcessConstant_Z_000[6].w);
      float _258 = _257 + _254;
      float _259 = _254 - _257;
      float _260 = max(_256, _259);
      float _261 = min(_260, _258);
      float _262 = _256 - _261;
      float _263 = _262 * (PostProcess_000.PostProcessConstant_Z_000[5].w);
      float _264 = _261 - (PostProcess_000.PostProcessConstant_Z_000[5].y);
      float _265 = _264 * _256;
      float _266 = _263 / _265;
      float _267 = min(_266, 0.0f);
      float _268 = _257 + 1.0f;
      float _269 = 1.0f / _268;
      float _270 = _267 * (PostProcess_000.PostProcessConstant_Z_000[7].z);
      float _271 = max(0.0f, _266);
      float _272 = _271 * (PostProcess_000.PostProcessConstant_Z_000[18].x);
      float _273 = _272 + _270;
      float _274 = _273 * _269;
      float _275 = max(_274, -1.0f);
      float _276 = min(_275, 1.0f);
      float _277 = max(_276, -0.30000001192092896f);
      float _278 = min(_277, 1.0f);
      float _279 = _278 * _206;
      float4 _280 = t2.SampleLevel(s2, float2(_235, _236), 0.0f);
      if (_156) {
        float4 _284 = t7.Load(int3(0, 0, 0));
        float _286 = _284.x - (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
        float _287 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _286;
        _291 = _287;
      } else {
        _291 = (PostProcess_000.PostProcessConstant_Z_000[5].x);
      }
      float _292 = _280.x - (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
      float _293 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _292;
      float _294 = _291 * (PostProcess_000.PostProcessConstant_Z_000[6].w);
      float _295 = _294 + _291;
      float _296 = _291 - _294;
      float _297 = max(_293, _296);
      float _298 = min(_297, _295);
      float _299 = _293 - _298;
      float _300 = _299 * (PostProcess_000.PostProcessConstant_Z_000[5].w);
      float _301 = _298 - (PostProcess_000.PostProcessConstant_Z_000[5].y);
      float _302 = _301 * _293;
      float _303 = _300 / _302;
      float _304 = min(_303, 0.0f);
      float _305 = _294 + 1.0f;
      float _306 = 1.0f / _305;
      float _307 = _304 * (PostProcess_000.PostProcessConstant_Z_000[7].z);
      float _308 = max(0.0f, _303);
      float _309 = _308 * (PostProcess_000.PostProcessConstant_Z_000[18].x);
      float _310 = _309 + _307;
      float _311 = _310 * _306;
      float _312 = max(_311, -1.0f);
      float _313 = min(_312, 1.0f);
      float _314 = max(_313, -0.30000001192092896f);
      float _315 = min(_314, 1.0f);
      float _316 = _315 * _206;
      float _317 = abs(_279);
      float _318 = _317 / (PostProcess_000.PostProcessConstant_Z_000[6].x);
      float _319 = ceil(_318);
      float _320 = saturate(_319);
      float _321 = _239.x - _135;
      float _322 = _320 * _321;
      float _323 = _322 + _135;
      float _324 = abs(_316);
      float _325 = _324 / (PostProcess_000.PostProcessConstant_Z_000[6].x);
      float _326 = ceil(_325);
      float _327 = saturate(_326);
      float _328 = _241.z - _137;
      float _329 = _327 * _328;
      float _330 = _329 + _137;
      _520 = _323;
      _521 = _136;
      _522 = _330;
    } else {
      _520 = _135;
      _521 = _136;
      _522 = _137;
    }
  } else {
    int _333 = asint((User_000.UserConstant_Z_000[7].y));
    bool _334 = ((int)_333 > (int)0);
    if (_334) {
      float _336 = _34.x + TEXCOORD.x;
      float _337 = _44 + TEXCOORD.y;
      float4 _340 = t4.Sample(s4, float2(_336, _337));
      float4 _347 = t5.Sample(s5, float2(_336, _337));
      float _351 = (PostProcess_000.PostProcessConstant_Z_000[6].x) * _347.x;
      float _355 = _351 * (PostProcess_000.PostProcessConstant_Z_000[7].x);
      float _356 = _351 * (PostProcess_000.PostProcessConstant_Z_000[7].y);
      float _357 = _355 + _336;
      float _358 = _356 + _337;
      float4 _359 = t4.Sample(s4, float2(_357, _358));
      float4 _361 = t5.Sample(s5, float2(_357, _358));
      float _363 = _361.x * (PostProcess_000.PostProcessConstant_Z_000[6].x);
      float _364 = abs(_363);
      float _366 = _364 / (PostProcess_000.PostProcessConstant_Z_000[7].w);
      float _367 = _359.z - _340.z;
      float _368 = _366 * _367;
      float _369 = _340.x - _135;
      float _370 = _340.y - _136;
      float _371 = _340.z - _137;
      float _372 = _371 + _368;
      float _373 = _369 * _340.w;
      float _374 = _370 * _340.w;
      float _375 = _372 * _340.w;
      float _376 = _373 + _135;
      float _377 = _374 + _136;
      float _378 = _375 + _137;
      _520 = _376;
      _521 = _377;
      _522 = _378;
    } else {
      int _381 = asint((User_000.UserConstant_Z_000[7].x));
      bool _382 = ((int)_381 > (int)0);
      [branch]
      if (_382) {
        float4 _386 = t7.Sample(s7, float2(TEXCOORD.x, TEXCOORD.y));
        float _388 = abs(_386.x);
        _481 = _388;
      } else {
        float4 _392 = t2.SampleLevel(s2, float2(TEXCOORD.x, TEXCOORD.y), 0.0f);
        float _394 = TEXCOORD.x * 2.0f;
        float _395 = TEXCOORD.y * 2.0f;
        float _396 = _394 + -1.0f;
        float _397 = _395 + -1.0f;
        float _418 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][8].x) * _396;
        float _419 = mad(_397, (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][8].y), _418);
        float _420 = mad(_392.x, (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][8].z), _419);
        float _421 = _420 + (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][8].w);
        float _422 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][9].x) * _396;
        float _423 = mad(_397, (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][9].y), _422);
        float _424 = mad(_392.x, (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][9].z), _423);
        float _425 = _424 + (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][9].w);
        float _426 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][10].x) * _396;
        float _427 = mad(_397, (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][10].y), _426);
        float _428 = mad(_392.x, (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][10].z), _427);
        float _429 = _428 + (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][10].w);
        float _430 = (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][11].x) * _396;
        float _431 = mad(_397, (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][11].y), _430);
        float _432 = mad(_392.x, (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][11].z), _431);
        float _433 = _432 + (Global_000.GlobalCB_Z_2688.GlobalCB_Z__ProjConstant_Z_000[0][11].w);
        float _434 = _421 / _433;
        float _435 = _425 / _433;
        float _436 = _429 / _433;
        float _437 = _434 * _434;
        float _438 = _435 * _435;
        float _439 = _438 + _437;
        float _440 = _436 * _436;
        float _441 = _439 + _440;
        float _442 = sqrt(_441);
        float4 _445 = t5.Sample(s5, float2(TEXCOORD.x, TEXCOORD.y));
        float _451 = (PostProcess_000.PostProcessConstant_Z_000[6].w) * (PostProcess_000.PostProcessConstant_Z_000[5].x);
        float _452 = _451 + (PostProcess_000.PostProcessConstant_Z_000[5].x);
        float _453 = (PostProcess_000.PostProcessConstant_Z_000[5].x) - _451;
        float _454 = max(_442, _453);
        float _455 = min(_454, _452);
        float _457 = _442 - _455;
        float _458 = _457 * (PostProcess_000.PostProcessConstant_Z_000[5].w);
        float _460 = _455 - (PostProcess_000.PostProcessConstant_Z_000[5].y);
        float _461 = _460 * _442;
        float _462 = _458 / _461;
        float _463 = min(_462, 0.0f);
        float _466 = _451 + 1.0f;
        float _467 = 1.0f / _466;
        float _468 = (PostProcess_000.PostProcessConstant_Z_000[7].z) * _463;
        float _469 = max(0.0f, _462);
        float _472 = (PostProcess_000.PostProcessConstant_Z_000[18].x) * _469;
        float _473 = _472 + _468;
        float _474 = _473 * _467;
        float _475 = min(_445.x, _474);
        float _476 = abs(_475);
        float _477 = abs(_474);
        float _478 = max(_476, _477);
        float _479 = saturate(_478);
        _481 = _479;
      }
      float _484 = (PostProcess_000.PostProcessConstant_Z_000[6].x) * _481;
      float4 _487 = t4.Sample(s4, float2(TEXCOORD.x, TEXCOORD.y));
      float _494 = (PostProcess_000.PostProcessConstant_Z_000[7].x) * _484;
      float _495 = (PostProcess_000.PostProcessConstant_Z_000[7].y) * _484;
      float _496 = _494 + TEXCOORD.x;
      float _497 = _495 + TEXCOORD.y;
      float4 _498 = t4.Sample(s4, float2(_496, _497));
      float4 _502 = t5.Sample(s5, float2(_496, _497));
      float _504 = abs(_502.x);
      float _505 = _498.z - _487.z;
      float _506 = _504 * _505;
      float _507 = _484 + -1.0f;
      float _508 = saturate(_507);
      float _509 = _487.x - _135;
      float _510 = _487.y - _136;
      float _511 = _487.z - _137;
      float _512 = _511 + _506;
      float _513 = _508 * _509;
      float _514 = _508 * _510;
      float _515 = _512 * _508;
      float _516 = _513 + _135;
      float _517 = _514 + _136;
      float _518 = _515 + _137;
      _520 = _516;
      _521 = _517;
      _522 = _518;
    }
  }
  float4 _526 = t17.Load(int3(0, 0, 0));
  float _532 = _526.x * (Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[87].y);
  float _533 = _532 * _520;
  float _534 = _533 * (PostProcess_000.PostProcessConstant_Z_000[14].x);
  float _535 = _532 * _521;
  float _536 = _535 * (PostProcess_000.PostProcessConstant_Z_000[14].y);
  float _537 = _532 * _522;
  float _538 = _537 * (PostProcess_000.PostProcessConstant_Z_000[14].z);
  float _543 = _54 * 2.0f;
  float _544 = _55 * 2.0f;
  float _545 = _543 + -1.0f;
  float _546 = _544 + -1.0f;
  float _549 = (PostProcess_000.PostProcessConstant_Z_000[13].w) * _546;
  float _550 = _545 * _545;
  float _551 = _549 * _549;
  float _552 = _551 + _550;
  float _553 = sqrt(_552);
  float _555 = (PostProcess_000.PostProcessConstant_Z_000[13].x) * _553;
  float _557 = _555 + (PostProcess_000.PostProcessConstant_Z_000[13].y);
  float _558 = saturate(_557);
  float _560 = log2(_558);
  float _561 = _560 * (PostProcess_000.PostProcessConstant_Z_000[13].z);
  float _562 = exp2(_561);
  float _563 = _534 * (PostProcess_000.PostProcessConstant_Z_000[12].x);
  float _564 = _536 * (PostProcess_000.PostProcessConstant_Z_000[12].y);
  float _565 = _538 * (PostProcess_000.PostProcessConstant_Z_000[12].z);
  float _566 = _563 - _534;
  float _567 = _564 - _536;
  float _568 = _565 - _538;
  float _569 = _562 * _566;
  float _570 = _562 * _567;
  float _571 = _562 * _568;
  float _572 = _569 + _534;
  float _573 = _570 + _536;
  float _574 = _571 + _538;
  float _577 = (PostProcess_000.PostProcessConstant_Z_000[10].w) * 1.1190600395202637f;
  float _578 = _577 * _572;
  float _579 = _577 * _573;
  float _580 = _577 * _574;
  float _581 = _578 + 1.0f;
  float _582 = _579 + 1.0f;
  float _583 = _580 + 1.0f;
  float _584 = log2(_581);
  float _585 = log2(_582);
  float _586 = log2(_583);
  float _589 = (PostProcess_000.PostProcessConstant_Z_320[0].x) * 0.07434873282909393f;
  float _590 = _589 * _584;
  float _591 = _589 * _585;
  float _592 = _589 * _586;
  float _594 = _590 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _595 = _591 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _596 = _592 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float4 _599 = t3.Sample(s3, float3(_594, _595, _596));
  float _605 = _599.x * 13.450128555297852f;
  float _606 = _599.y * 13.450128555297852f;
  float _607 = _599.z * 13.450128555297852f;
  float _608 = exp2(_605);
  float _609 = exp2(_606);
  float _610 = exp2(_607);
  float _611 = _608 + -1.0f;
  float _612 = _609 + -1.0f;
  float _613 = _610 + -1.0f;
  float _614 = 0.8936070799827576f / (PostProcess_000.PostProcessConstant_Z_000[10].w);
  float _615 = _614 * _611;
  float _616 = _614 * _612;
  float _617 = _614 * _613;
  float3 resonance_scaled_lut_output = ResonanceApplyPostProcessLUT(
      float3(_578 * _614, _579 * _614, _580 * _614),
      float3(_615, _616, _617),
      1.f.xxx);
  _615 = resonance_scaled_lut_output.x;
  _616 = resonance_scaled_lut_output.y;
  _617 = resonance_scaled_lut_output.z;
  bool _620 = ((User_000.UserConstant_Z_000[3].x) > 0.0f) && !ResonanceIsPsychoV();
  if (_620) {
    float _622 = (PostProcess_000.PostProcessConstant_Z_000[10].w) * 1.1190600395202637f;
    float _623 = _615 * _622;
    float _624 = _616 * _622;
    float _625 = _617 * _622;
    float _626 = _623 + 1.0f;
    float _627 = _624 + 1.0f;
    float _628 = _625 + 1.0f;
    float _629 = log2(_626);
    float _630 = log2(_627);
    float _631 = log2(_628);
    float _632 = _629 * 0.07434873282909393f;
    float _633 = _630 * 0.07434873282909393f;
    float _634 = _631 * 0.07434873282909393f;
    int _636 = asint((User_000.UserConstant_Z_000[3].y));
    int _637 = _636 & 1;
    bool _638 = (_637 == 0);
    if (!_638) {
      bool _655 = !(_632 <= (User_000.UserConstant_Z_000[4].x));
      if (!_655) {
        float _657 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _658 = _632 / _657;
        float _659 = _658 * (User_000.UserConstant_Z_000[4].y);
        float _660 = _658 * _658;
        float _661 = _660 * _658;
        float _662 = _661 - _658;
        float _663 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _664 = _657 * _657;
        float _665 = _664 * _663;
        float _666 = _665 * _662;
        float _667 = _666 + _659;
        _757 = _667;
      } else {
        bool _669 = !(_632 <= (User_000.UserConstant_Z_000[4].z));
        if (!_669) {
          float _671 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _672 = max(9.999999974752427e-07f, _671);
          float _673 = _632 - (User_000.UserConstant_Z_000[4].x);
          float _674 = _673 / _672;
          float _675 = 1.0f - _674;
          float _676 = _675 * (User_000.UserConstant_Z_000[4].y);
          float _677 = _674 * (User_000.UserConstant_Z_000[4].w);
          float _678 = _676 + _677;
          float _679 = _675 * _675;
          float _680 = _679 * _675;
          float _681 = _680 - _675;
          float _682 = _681 * (User_000.UserConstant_Z_000[10].x);
          float _683 = _674 * _674;
          float _684 = _683 * _674;
          float _685 = _684 - _674;
          float _686 = _685 * (User_000.UserConstant_Z_000[10].y);
          float _687 = _682 + _686;
          float _688 = _672 * _672;
          float _689 = _688 * 0.1666666716337204f;
          float _690 = _689 * _687;
          float _691 = _678 + _690;
          _757 = _691;
        } else {
          bool _693 = !(_632 <= (User_000.UserConstant_Z_000[9].x));
          if (!_693) {
            float _695 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _696 = max(9.999999974752427e-07f, _695);
            float _697 = _632 - (User_000.UserConstant_Z_000[4].z);
            float _698 = _697 / _696;
            float _699 = 1.0f - _698;
            float _700 = _699 * (User_000.UserConstant_Z_000[4].w);
            float _701 = _698 * (User_000.UserConstant_Z_000[9].y);
            float _702 = _700 + _701;
            float _703 = _699 * _699;
            float _704 = _703 * _699;
            float _705 = _704 - _699;
            float _706 = _705 * (User_000.UserConstant_Z_000[10].y);
            float _707 = _698 * _698;
            float _708 = _707 * _698;
            float _709 = _708 - _698;
            float _710 = _709 * (User_000.UserConstant_Z_000[10].z);
            float _711 = _706 + _710;
            float _712 = _696 * _696;
            float _713 = _712 * 0.1666666716337204f;
            float _714 = _713 * _711;
            float _715 = _702 + _714;
            _757 = _715;
          } else {
            bool _717 = !(_632 <= (User_000.UserConstant_Z_000[9].z));
            if (!_717) {
              float _719 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _720 = max(9.999999974752427e-07f, _719);
              float _721 = _632 - (User_000.UserConstant_Z_000[9].x);
              float _722 = _721 / _720;
              float _723 = 1.0f - _722;
              float _724 = _723 * (User_000.UserConstant_Z_000[9].y);
              float _725 = _722 * (User_000.UserConstant_Z_000[9].w);
              float _726 = _724 + _725;
              float _727 = _723 * _723;
              float _728 = _727 * _723;
              float _729 = _728 - _723;
              float _730 = _729 * (User_000.UserConstant_Z_000[10].z);
              float _731 = _722 * _722;
              float _732 = _731 * _722;
              float _733 = _732 - _722;
              float _734 = _733 * (User_000.UserConstant_Z_000[10].w);
              float _735 = _730 + _734;
              float _736 = _720 * _720;
              float _737 = _736 * 0.1666666716337204f;
              float _738 = _737 * _735;
              float _739 = _726 + _738;
              _757 = _739;
            } else {
              float _741 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _742 = _632 - (User_000.UserConstant_Z_000[9].z);
              float _743 = max(9.999999974752427e-07f, _741);
              float _744 = _742 / _743;
              float _745 = 1.0f - _744;
              float _746 = _745 * (User_000.UserConstant_Z_000[9].w);
              float _747 = _746 + _744;
              float _748 = _745 * _745;
              float _749 = _748 * _745;
              float _750 = _749 - _745;
              float _751 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _752 = _741 * _741;
              float _753 = _752 * _751;
              float _754 = _753 * _750;
              float _755 = _747 + _754;
              _757 = _755;
            }
          }
        }
      }
      float _758 = saturate(_757);
      bool _759 = !(_633 <= (User_000.UserConstant_Z_000[4].x));
      if (!_759) {
        float _761 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _762 = _633 / _761;
        float _763 = _762 * (User_000.UserConstant_Z_000[4].y);
        float _764 = _762 * _762;
        float _765 = _764 * _762;
        float _766 = _765 - _762;
        float _767 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _768 = _761 * _761;
        float _769 = _768 * _767;
        float _770 = _769 * _766;
        float _771 = _770 + _763;
        _861 = _771;
      } else {
        bool _773 = !(_633 <= (User_000.UserConstant_Z_000[4].z));
        if (!_773) {
          float _775 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _776 = max(9.999999974752427e-07f, _775);
          float _777 = _633 - (User_000.UserConstant_Z_000[4].x);
          float _778 = _777 / _776;
          float _779 = 1.0f - _778;
          float _780 = _779 * (User_000.UserConstant_Z_000[4].y);
          float _781 = _778 * (User_000.UserConstant_Z_000[4].w);
          float _782 = _780 + _781;
          float _783 = _779 * _779;
          float _784 = _783 * _779;
          float _785 = _784 - _779;
          float _786 = _785 * (User_000.UserConstant_Z_000[10].x);
          float _787 = _778 * _778;
          float _788 = _787 * _778;
          float _789 = _788 - _778;
          float _790 = _789 * (User_000.UserConstant_Z_000[10].y);
          float _791 = _786 + _790;
          float _792 = _776 * _776;
          float _793 = _792 * 0.1666666716337204f;
          float _794 = _793 * _791;
          float _795 = _782 + _794;
          _861 = _795;
        } else {
          bool _797 = !(_633 <= (User_000.UserConstant_Z_000[9].x));
          if (!_797) {
            float _799 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _800 = max(9.999999974752427e-07f, _799);
            float _801 = _633 - (User_000.UserConstant_Z_000[4].z);
            float _802 = _801 / _800;
            float _803 = 1.0f - _802;
            float _804 = _803 * (User_000.UserConstant_Z_000[4].w);
            float _805 = _802 * (User_000.UserConstant_Z_000[9].y);
            float _806 = _804 + _805;
            float _807 = _803 * _803;
            float _808 = _807 * _803;
            float _809 = _808 - _803;
            float _810 = _809 * (User_000.UserConstant_Z_000[10].y);
            float _811 = _802 * _802;
            float _812 = _811 * _802;
            float _813 = _812 - _802;
            float _814 = _813 * (User_000.UserConstant_Z_000[10].z);
            float _815 = _810 + _814;
            float _816 = _800 * _800;
            float _817 = _816 * 0.1666666716337204f;
            float _818 = _817 * _815;
            float _819 = _806 + _818;
            _861 = _819;
          } else {
            bool _821 = !(_633 <= (User_000.UserConstant_Z_000[9].z));
            if (!_821) {
              float _823 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _824 = max(9.999999974752427e-07f, _823);
              float _825 = _633 - (User_000.UserConstant_Z_000[9].x);
              float _826 = _825 / _824;
              float _827 = 1.0f - _826;
              float _828 = _827 * (User_000.UserConstant_Z_000[9].y);
              float _829 = _826 * (User_000.UserConstant_Z_000[9].w);
              float _830 = _828 + _829;
              float _831 = _827 * _827;
              float _832 = _831 * _827;
              float _833 = _832 - _827;
              float _834 = _833 * (User_000.UserConstant_Z_000[10].z);
              float _835 = _826 * _826;
              float _836 = _835 * _826;
              float _837 = _836 - _826;
              float _838 = _837 * (User_000.UserConstant_Z_000[10].w);
              float _839 = _834 + _838;
              float _840 = _824 * _824;
              float _841 = _840 * 0.1666666716337204f;
              float _842 = _841 * _839;
              float _843 = _830 + _842;
              _861 = _843;
            } else {
              float _845 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _846 = _633 - (User_000.UserConstant_Z_000[9].z);
              float _847 = max(9.999999974752427e-07f, _845);
              float _848 = _846 / _847;
              float _849 = 1.0f - _848;
              float _850 = _849 * (User_000.UserConstant_Z_000[9].w);
              float _851 = _850 + _848;
              float _852 = _849 * _849;
              float _853 = _852 * _849;
              float _854 = _853 - _849;
              float _855 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _856 = _845 * _845;
              float _857 = _856 * _855;
              float _858 = _857 * _854;
              float _859 = _851 + _858;
              _861 = _859;
            }
          }
        }
      }
      float _862 = saturate(_861);
      bool _863 = !(_634 <= (User_000.UserConstant_Z_000[4].x));
      if (!_863) {
        float _865 = max(9.999999974752427e-07f, (User_000.UserConstant_Z_000[4].x));
        float _866 = _634 / _865;
        float _867 = _866 * (User_000.UserConstant_Z_000[4].y);
        float _868 = _866 * _866;
        float _869 = _868 * _866;
        float _870 = _869 - _866;
        float _871 = (User_000.UserConstant_Z_000[10].x) * 0.1666666716337204f;
        float _872 = _865 * _865;
        float _873 = _872 * _871;
        float _874 = _873 * _870;
        float _875 = _874 + _867;
        _965 = _875;
      } else {
        bool _877 = !(_634 <= (User_000.UserConstant_Z_000[4].z));
        if (!_877) {
          float _879 = (User_000.UserConstant_Z_000[4].z) - (User_000.UserConstant_Z_000[4].x);
          float _880 = max(9.999999974752427e-07f, _879);
          float _881 = _634 - (User_000.UserConstant_Z_000[4].x);
          float _882 = _881 / _880;
          float _883 = 1.0f - _882;
          float _884 = _883 * (User_000.UserConstant_Z_000[4].y);
          float _885 = _882 * (User_000.UserConstant_Z_000[4].w);
          float _886 = _884 + _885;
          float _887 = _883 * _883;
          float _888 = _887 * _883;
          float _889 = _888 - _883;
          float _890 = _889 * (User_000.UserConstant_Z_000[10].x);
          float _891 = _882 * _882;
          float _892 = _891 * _882;
          float _893 = _892 - _882;
          float _894 = _893 * (User_000.UserConstant_Z_000[10].y);
          float _895 = _890 + _894;
          float _896 = _880 * _880;
          float _897 = _896 * 0.1666666716337204f;
          float _898 = _897 * _895;
          float _899 = _886 + _898;
          _965 = _899;
        } else {
          bool _901 = !(_634 <= (User_000.UserConstant_Z_000[9].x));
          if (!_901) {
            float _903 = (User_000.UserConstant_Z_000[9].x) - (User_000.UserConstant_Z_000[4].z);
            float _904 = max(9.999999974752427e-07f, _903);
            float _905 = _634 - (User_000.UserConstant_Z_000[4].z);
            float _906 = _905 / _904;
            float _907 = 1.0f - _906;
            float _908 = _907 * (User_000.UserConstant_Z_000[4].w);
            float _909 = _906 * (User_000.UserConstant_Z_000[9].y);
            float _910 = _908 + _909;
            float _911 = _907 * _907;
            float _912 = _911 * _907;
            float _913 = _912 - _907;
            float _914 = _913 * (User_000.UserConstant_Z_000[10].y);
            float _915 = _906 * _906;
            float _916 = _915 * _906;
            float _917 = _916 - _906;
            float _918 = _917 * (User_000.UserConstant_Z_000[10].z);
            float _919 = _914 + _918;
            float _920 = _904 * _904;
            float _921 = _920 * 0.1666666716337204f;
            float _922 = _921 * _919;
            float _923 = _910 + _922;
            _965 = _923;
          } else {
            bool _925 = !(_634 <= (User_000.UserConstant_Z_000[9].z));
            if (!_925) {
              float _927 = (User_000.UserConstant_Z_000[9].z) - (User_000.UserConstant_Z_000[9].x);
              float _928 = max(9.999999974752427e-07f, _927);
              float _929 = _634 - (User_000.UserConstant_Z_000[9].x);
              float _930 = _929 / _928;
              float _931 = 1.0f - _930;
              float _932 = _931 * (User_000.UserConstant_Z_000[9].y);
              float _933 = _930 * (User_000.UserConstant_Z_000[9].w);
              float _934 = _932 + _933;
              float _935 = _931 * _931;
              float _936 = _935 * _931;
              float _937 = _936 - _931;
              float _938 = _937 * (User_000.UserConstant_Z_000[10].z);
              float _939 = _930 * _930;
              float _940 = _939 * _930;
              float _941 = _940 - _930;
              float _942 = _941 * (User_000.UserConstant_Z_000[10].w);
              float _943 = _938 + _942;
              float _944 = _928 * _928;
              float _945 = _944 * 0.1666666716337204f;
              float _946 = _945 * _943;
              float _947 = _934 + _946;
              _965 = _947;
            } else {
              float _949 = 1.0f - (User_000.UserConstant_Z_000[9].z);
              float _950 = _634 - (User_000.UserConstant_Z_000[9].z);
              float _951 = max(9.999999974752427e-07f, _949);
              float _952 = _950 / _951;
              float _953 = 1.0f - _952;
              float _954 = _953 * (User_000.UserConstant_Z_000[9].w);
              float _955 = _954 + _952;
              float _956 = _953 * _953;
              float _957 = _956 * _953;
              float _958 = _957 - _953;
              float _959 = (User_000.UserConstant_Z_000[10].w) * 0.1666666716337204f;
              float _960 = _949 * _949;
              float _961 = _960 * _959;
              float _962 = _961 * _958;
              float _963 = _955 + _962;
              _965 = _963;
            }
          }
        }
      }
      float _966 = saturate(_965);
      _968 = _758;
      _969 = _862;
      _970 = _966;
    } else {
      _968 = _632;
      _969 = _633;
      _970 = _634;
    }
    int _971 = _636 & 2;
    bool _972 = (_971 == 0);
    if (!_972) {
      float _974 = sqrt(_968);
      float _975 = sqrt(_969);
      float _976 = sqrt(_970);
      float _977 = dot(float3(_974, _975, _976), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
      float _978 = 1.0f - _977;
      float _979 = saturate(_978);
      _981 = _979;
    } else {
      _981 = 1.0f;
    }
    int _982 = _636 & 8;
    bool _983 = (_982 == 0);
    if (_983) {
      int _985 = _636 & 4;
      bool _986 = (_985 == 0);
      if (!_986) {
        int _988 = _636 & 16;
        bool _989 = (_988 == 0);
        if (!_989) {
          float _993 = (User_000.UserConstant_Z_000[5].x) * 0.5f;
          float _994 = _993 + 0.5f;
          bool _995 = (_994 < 0.5f);
          float _996 = (User_000.UserConstant_Z_000[5].x) * 5.0f;
          float _997 = select(_995, (User_000.UserConstant_Z_000[5].x), _996);
          bool _998 = (_969 < _970);
          float _999 = select(_998, _970, _969);
          float _1000 = select(_998, _969, _970);
          bool _1001 = (_968 < _999);
          float _1002 = select(_1001, _999, _968);
          float _1003 = select(_1001, _968, _999);
          float _1004 = min(_1003, _1000);
          float _1005 = _1002 - _1004;
          float _1006 = _1002 + 1.000000013351432e-10f;
          float _1007 = _1005 / _1006;
          float _1009 = _1007 - (User_000.UserConstant_Z_000[5].y);
          float _1010 = saturate(_1009);
          float _1011 = max(_1010, 9.999999974752427e-07f);
          float _1012 = log2(_1011);
          float _1013 = _1012 * _997;
          float _1014 = exp2(_1013);
          float _1015 = 2.0f - _1014;
          float _1017 = 1.0f - (User_000.UserConstant_Z_000[5].z);
          float _1018 = saturate(_1017);
          float _1019 = max(_1018, _1015);
          float _1020 = dot(float3(_968, _969, _970), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
          float _1021 = _968 - _1020;
          float _1022 = _969 - _1020;
          float _1023 = _970 - _1020;
          float _1024 = _1021 * _1019;
          float _1025 = _1022 * _1019;
          float _1026 = _1023 * _1019;
          float _1027 = _1020 - _968;
          float _1028 = _1027 + _1024;
          float _1029 = _1020 - _969;
          float _1030 = _1029 + _1025;
          float _1031 = _1020 - _970;
          float _1032 = _1031 + _1026;
          float _1033 = _1028 * _981;
          float _1034 = _1030 * _981;
          float _1035 = _1032 * _981;
          float _1036 = _1033 + _968;
          float _1037 = _1034 + _969;
          float _1038 = _1035 + _970;
          _1155 = _1036;
          _1156 = _1037;
          _1157 = _1038;
        } else {
          bool _1040 = (_981 == 0.0f);
          if (!_1040) {
            float _1044 = abs(User_000.UserConstant_Z_000[5].x);
            float _1045 = saturate(_1044);
            uint4 _1047 = 0u; t15.GetDimensions(0u, _1047.x, _1047.y, _1047.w);
            float _1050 = float((uint)_1047.y);
            int _1051 = _636 & 32;
            bool _1052 = (_1051 == 0);
            float _1053 = _1050 + -1.0f;
            if (!_1052) {
              float _1055 = 1.0f / _1053;
              uint _1056 = uint(SV_Position.x);
              uint _1057 = uint(SV_Position.y);
              int _1058 = _1056 & 63;
              int _1059 = _1057 & 63;
              float4 _1061 = t6.Load(int4(_1058, _1059, 0, 0));
              float _1064 = _1061.x + -0.5f;
              float _1065 = _968 * 13.999999046325684f;
              float _1066 = _969 * 13.999999046325684f;
              float _1067 = _970 * 13.999999046325684f;
              float _1068 = saturate(_1065);
              float _1069 = saturate(_1066);
              float _1070 = saturate(_1067);
              float _1071 = _968 + -0.9285714030265808f;
              float _1072 = _969 + -0.9285714030265808f;
              float _1073 = _970 + -0.9285714030265808f;
              float _1074 = _1071 * 13.999999046325684f;
              float _1075 = _1072 * 13.999999046325684f;
              float _1076 = _1073 * 13.999999046325684f;
              float _1077 = saturate(_1074);
              float _1078 = saturate(_1075);
              float _1079 = saturate(_1076);
              float _1080 = 1.0f - _1077;
              float _1081 = 1.0f - _1078;
              float _1082 = 1.0f - _1079;
              float _1083 = min(_1068, _1080);
              float _1084 = min(_1069, _1081);
              float _1085 = min(_1070, _1082);
              float _1086 = _1061.y + -0.5f;
              float _1087 = _1083 * _1086;
              float _1088 = _1084 * _1086;
              float _1089 = _1085 * _1086;
              float _1090 = _1087 + _1064;
              float _1091 = _1088 + _1064;
              float _1092 = _1089 + _1064;
              float _1093 = _1090 * _1055;
              float _1094 = _1091 * _1055;
              float _1095 = _1092 * _1055;
              float _1096 = _1093 + _968;
              float _1097 = _1094 + _969;
              float _1098 = _1095 + _970;
              float _1099 = saturate(_1096);
              float _1100 = saturate(_1097);
              float _1101 = saturate(_1098);
              float _1102 = saturate(_1099);
              float _1103 = saturate(_1100);
              float _1104 = saturate(_1101);
              _1106 = _1102;
              _1107 = _1103;
              _1108 = _1104;
            } else {
              _1106 = _968;
              _1107 = _969;
              _1108 = _970;
            }
            float _1109 = float((uint)_1047.x);
            float _1110 = _1053 / _1109;
            float _1111 = _1110 * _1106;
            float _1112 = 0.5f / _1109;
            float _1113 = _1111 + _1112;
            float _1114 = _1053 / _1050;
            float _1115 = _1114 * _1107;
            float _1116 = 0.5f / _1050;
            float _1117 = _1115 + _1116;
            float _1118 = _1108 * _1053;
            float _1119 = floor(_1118);
            float _1120 = frac(_1118);
            float _1121 = _1119 / _1050;
            float _1122 = _1121 + _1113;
            float _1123 = _1119 + 1.0f;
            float _1124 = _1123 / _1050;
            float _1125 = _1124 + _1113;
            float4 _1127 = t15.Sample(s0, float2(_1122, _1117));
            float4 _1131 = t15.Sample(s0, float2(_1125, _1117));
            float _1135 = _1131.x - _1127.x;
            float _1136 = _1131.y - _1127.y;
            float _1137 = _1131.z - _1127.z;
            float _1138 = _1135 * _1120;
            float _1139 = _1136 * _1120;
            float _1140 = _1137 * _1120;
            float _1141 = _1045 * _981;
            float _1142 = _1127.x - _968;
            float _1143 = _1142 + _1138;
            float _1144 = _1127.y - _969;
            float _1145 = _1144 + _1139;
            float _1146 = _1127.z - _970;
            float _1147 = _1146 + _1140;
            float _1148 = _1143 * _1141;
            float _1149 = _1145 * _1141;
            float _1150 = _1147 * _1141;
            float _1151 = _1148 + _968;
            float _1152 = _1149 + _969;
            float _1153 = _1150 + _970;
            _1155 = _1151;
            _1156 = _1152;
            _1157 = _1153;
          } else {
            _1155 = _968;
            _1156 = _969;
            _1157 = _970;
          }
        }
      } else {
        _1155 = _968;
        _1156 = _969;
        _1157 = _970;
      }
    } else {
      _1155 = _981;
      _1156 = _981;
      _1157 = _981;
    }
    float _1158 = _1155 * 13.450128555297852f;
    float _1159 = _1156 * 13.450128555297852f;
    float _1160 = _1157 * 13.450128555297852f;
    float _1161 = exp2(_1158);
    float _1162 = exp2(_1159);
    float _1163 = exp2(_1160);
    float _1164 = _1161 + -1.0f;
    float _1165 = _1162 + -1.0f;
    float _1166 = _1163 + -1.0f;
    float _1167 = _1164 * _614;
    float _1168 = _1165 * _614;
    float _1169 = _1166 * _614;
    _1171 = _1167;
    _1172 = _1168;
    _1173 = _1169;
  } else {
    _1171 = _615;
    _1172 = _616;
    _1173 = _617;
  }
  float3 resonance_perceptual_film_grain = ResonanceApplyPerceptualFilmGrain(
      float3((User_000.UserConstant_Z_000[8].x) * _1171, (User_000.UserConstant_Z_000[8].y) * _1172, (User_000.UserConstant_Z_000[8].z) * _1173),
      SV_Position.xy);
  float _1180 = resonance_perceptual_film_grain.x;
  float _1181 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 2.0f;
  float _1182 = log2(_1180);
  float _1183 = _1181 * _1182;
  float _1184 = exp2(_1183);
  float _1185 = _1184 + -1.0f;
  float _1186 = _1180 + -1.0f;
  float _1187 = _1185 / _1186;
  bool _1188 = !(_1180 == 1.0f);
  float _1189 = _1187 + -1.0f;
  float _1190 = _1189 / _1187;
  float _1191 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _1192 = _1191 / _1181;
  float _1193 = select(_1188, _1190, _1192);
  float _1194 = resonance_perceptual_film_grain.y;
  float _1195 = log2(_1194);
  float _1196 = _1195 * _1181;
  float _1197 = exp2(_1196);
  float _1198 = _1197 + -1.0f;
  float _1199 = _1194 + -1.0f;
  float _1200 = _1198 / _1199;
  bool _1201 = !(_1194 == 1.0f);
  float _1202 = _1200 + -1.0f;
  float _1203 = _1202 / _1200;
  float _1204 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _1205 = _1204 / _1181;
  float _1206 = select(_1201, _1203, _1205);
  float _1207 = resonance_perceptual_film_grain.z;
  float _1208 = log2(_1207);
  float _1209 = _1208 * _1181;
  float _1210 = exp2(_1209);
  float _1211 = _1210 + -1.0f;
  float _1212 = _1207 + -1.0f;
  float _1213 = _1211 / _1212;
  bool _1214 = !(_1207 == 1.0f);
  float _1215 = _1213 + -1.0f;
  float _1216 = _1215 / _1213;
  float _1217 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _1218 = _1217 / _1181;
  float _1219 = select(_1214, _1216, _1218);
  float3 resonance_post_process_output = ResonanceApplyPostProcessToneMap(
      float3(_1180, _1194, _1207),
      float3(_1193, _1206, _1219),
      true);
  float _1220 = resonance_post_process_output.x;
  float _1221 = resonance_post_process_output.y;
  float _1222 = resonance_post_process_output.z;
  float _1223 = log2(_1220);
  float _1224 = log2(_1221);
  float _1225 = log2(_1222);
  float _1226 = _1223 * 0.4166666567325592f;
  float _1227 = _1224 * 0.4166666567325592f;
  float _1228 = _1225 * 0.4166666567325592f;
  float _1229 = exp2(_1226);
  float _1230 = exp2(_1227);
  float _1231 = exp2(_1228);
  float _1232 = _1229 * 1.0549999475479126f;
  float _1233 = _1230 * 1.0549999475479126f;
  float _1234 = _1231 * 1.0549999475479126f;
  float _1235 = _1232 + -0.054999999701976776f;
  float _1236 = _1233 + -0.054999999701976776f;
  float _1237 = _1234 + -0.054999999701976776f;
  float _1238 = _1220 * 12.920000076293945f;
  float _1239 = _1221 * 12.920000076293945f;
  float _1240 = _1222 * 12.920000076293945f;
  bool _1241 = (_1220 <= 0.0031308000907301903f);
  bool _1242 = (_1221 <= 0.0031308000907301903f);
  bool _1243 = (_1222 <= 0.0031308000907301903f);
  float _1244 = select(_1241, _1238, _1235);
  float _1245 = select(_1242, _1239, _1236);
  float _1246 = select(_1243, _1240, _1237);
  int _1249 = asint((Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[1].w));
  uint _1250 = uint(SV_Position.x);
  uint _1251 = uint(SV_Position.y);
  int _1252 = _1250 & 63;
  int _1253 = _1251 & 63;
  float4 _1255 = t1.Load(int4(_1252, _1253, _1249, 0));
  float _1257 = _1255.x + -0.5f;
  float _1258 = _1257 * 0.003921568859368563f;
  float _1259 = _1258 + _1244;
  float _1260 = _1258 + _1245;
  float _1261 = _1258 + _1246;
  float _1262 = saturate(_1259);
  float _1263 = saturate(_1260);
  float _1264 = saturate(_1261);
  SV_Target.x = _1262;
  SV_Target.y = _1263;
  SV_Target.z = _1264;
  SV_Target.w = _132.w;
  if (ResonanceIsPsychoV()) {
    SV_Target.rgb = ResonanceRenderIntermediatePassDithered(
        resonance_post_process_output, SV_Position.xy);
  }
  return SV_Target;
}