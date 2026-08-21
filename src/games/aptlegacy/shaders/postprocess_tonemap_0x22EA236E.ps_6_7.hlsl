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

SamplerState s14 : register(s14);

float4 main(
  linear float4 TEXCOORD : TEXCOORD,
  noperspective float4 SV_Position : SV_Position
) : SV_Target {
  float4 SV_Target;
  float4 _33 = t14.Sample(s14, float2(TEXCOORD.x, TEXCOORD.y));
  float4 _39 = t16.Sample(s0, float2(TEXCOORD.z, TEXCOORD.w));
  float _42 = _39.y * 0.10000000149011612f;
  float _43 = _42 + _33.y;
  float _44 = _39.y * 0.5f;
  float _45 = _44 + _33.z;
  float _46 = exp2(_45);
  float _47 = _46 + -1.0f;
  float _50 = (PostProcess_000.PostProcessConstant_Z_000[11].y) * _47;
  float _51 = _50 + 1.0f;
  float _52 = log2(_51);
  float _53 = _33.x + TEXCOORD.z;
  float _54 = _43 + TEXCOORD.w;
  float _55 = _33.x + TEXCOORD.x;
  float _56 = _43 + TEXCOORD.y;
  float _57 = _52 + 1.0f;
  float _58 = log2(_57);
  float _62 = 0.5f - (PostProcess_000.PostProcessConstant_Z_000[19].x);
  float _63 = 0.5f - (PostProcess_000.PostProcessConstant_Z_000[19].y);
  float _64 = _62 + _53;
  float _65 = _63 + _54;
  float _66 = _64 * 2.0f;
  float _67 = _65 * 2.0f;
  float _68 = _66 + -1.0f;
  float _69 = _67 + -1.0f;
  float _73 = _69 * (Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[51].y);
  float _74 = abs(_68);
  float _75 = abs(_69);
  float _77 = (PostProcess_000.PostProcessConstant_Z_000[19].z) * 2.0f;
  float _78 = _77 + -1.0f;
  float _79 = _74 - _78;
  float _80 = _75 - _78;
  float _81 = saturate(_79);
  float _82 = saturate(_80);
  float _83 = _81 * (Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[51].x);
  float _84 = _83 * _68;
  float _85 = _73 * _82;
  float _86 = _84 * _84;
  float _87 = _85 * _85;
  float _88 = _86 + _87;
  float _89 = sqrt(_88);
  float _92 = _55 + _62;
  float _93 = _56 + _63;
  float _94 = _92 * 2.0f;
  float _95 = _94 + -1.0f;
  float _96 = _93 * 1.125f;
  float _97 = _96 + -0.5625f;
  float _98 = _95 * _95;
  float _99 = _97 * _97;
  float _100 = _98 + _99;
  float _101 = sqrt(_100);
  float _102 = _101 * 0.8715755343437195f;
  float _103 = _102 * _102;
  float _104 = _103 + -0.15000000596046448f;
  float _105 = _104 * 1.8181819915771484f;
  float _106 = saturate(_105);
  float _107 = _106 * 2.0f;
  float _108 = 3.0f - _107;
  float _109 = (PostProcess_000.PostProcessConstant_Z_000[2].w) * _89;
  float _110 = _106 * _106;
  float _111 = _110 * _109;
  float _112 = _111 * _103;
  float _113 = _112 * _108;
  float _115 = (PostProcess_000.PostProcessConstant_Z_000[2].z) * _84;
  float _116 = (PostProcess_000.PostProcessConstant_Z_000[2].z) * _85;
  float _117 = _116 + _54;
  float _118 = _53 - _115;
  float _119 = _39.x * 0.010840999893844128f;
  float _120 = _53 + _119;
  float _121 = _120 + _115;
  float _122 = _54 + _119;
  float _123 = _122 - _116;
  float _124 = max(_113, _58);
  float4 _127 = t0.SampleLevel(s0, float2(_121, _117), _124);
  float4 _129 = t0.SampleLevel(s0, float2(_118, _123), _124);
  float4 _131 = t0.SampleLevel(s0, float2(_53, _54), _124);
  float _134 = max(_127.x, 0.0f);
  float _135 = max(_129.y, 0.0f);
  float _136 = max(_131.z, 0.0f);
  int _139 = asint((User_000.UserConstant_Z_000[3].z));
  bool _140 = ((int)_139 > (int)0);
  float _169;
  float _254;
  float _291;
  float _481;
  float _520;
  float _521;
  float _522;
  [branch]
  if (_140) {
    bool _145 = ((PostProcess_000.PostProcessConstant_Z_000[7].x) > 0.0f);
    if (_145) {
      float _147 = _33.x + TEXCOORD.x;
      float _148 = _43 + TEXCOORD.y;
      float4 _151 = t2.SampleLevel(s2, float2(_147, _148), 0.0f);
      bool _155 = ((PostProcess_000.PostProcessConstant_Z_000[6].y) == 1.0f);
      if (_155) {
        float4 _158 = t7.Load(int3(0, 0, 0));
        float _163 = _158.x - (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
        float _164 = (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _163;
        _169 = _164;
      } else {
        _169 = (PostProcess_000.PostProcessConstant_Z_000[5].x);
      }
      float _173 = _151.x - (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
      float _174 = (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _173;
      float _176 = _169 * (PostProcess_000.PostProcessConstant_Z_000[6].w);
      float _177 = _176 + _169;
      float _178 = _169 - _176;
      float _179 = max(_174, _178);
      float _180 = min(_179, _177);
      float _183 = _174 - _180;
      float _184 = (PostProcess_000.PostProcessConstant_Z_000[5].w) * _183;
      float _186 = _180 - (PostProcess_000.PostProcessConstant_Z_000[5].y);
      float _187 = _186 * _174;
      float _188 = _184 / _187;
      float _189 = min(_188, 0.0f);
      float _191 = _176 + 1.0f;
      float _192 = 1.0f / _191;
      float _193 = _189 * (PostProcess_000.PostProcessConstant_Z_000[7].z);
      float _194 = max(0.0f, _188);
      float _197 = (PostProcess_000.PostProcessConstant_Z_000[18].x) * _194;
      float _198 = _197 + _193;
      float _199 = _198 * _192;
      float _200 = max(_199, -1.0f);
      float _201 = min(_200, 1.0f);
      float _202 = max(_201, -0.30000001192092896f);
      float _203 = min(_202, 1.0f);
      float _205 = -0.0f - (PostProcess_000.PostProcessConstant_Z_000[6].x);
      float _206 = _203 * _205;
      float _207 = _147 + -0.5f;
      float _208 = _148 + -0.5f;
      float _209 = _207 * _207;
      float _210 = _208 * _208;
      float _211 = _210 + _209;
      float _212 = sqrt(_211);
      float _213 = log2(_212);
      float _214 = _213 * (PostProcess_000.PostProcessConstant_Z_000[7].y);
      float _215 = exp2(_214);
      float _216 = _215 * (PostProcess_000.PostProcessConstant_Z_000[7].x);
      float _217 = dot(float2(_207, _208), float2(_207, _208));
      float _218 = rsqrt(_217);
      float _219 = _218 * _207;
      float _220 = _218 * _208;
      float _221 = abs(_206);
      float _225 = _216 * _221;
      float _226 = -0.0f - _225;
      float _227 = (User_000.UserConstant_Z_000[2].x) * _219;
      float _228 = _227 * _226;
      float _229 = (User_000.UserConstant_Z_000[2].y) * _220;
      float _230 = _229 * _226;
      float _231 = _221 * _216;
      float _232 = _227 * _231;
      float _233 = _229 * _231;
      float _234 = _232 + _147;
      float _235 = _233 + _148;
      float _236 = _228 + _121;
      float _237 = _230 + _117;
      float _238 = max(_58, _124);
      float4 _239 = t0.SampleLevel(s0, float2(_236, _237), _238);
      float4 _241 = t0.SampleLevel(s0, float2(_234, _235), _238);
      float4 _243 = t2.SampleLevel(s2, float2(_236, _237), 0.0f);
      if (_155) {
        float4 _247 = t7.Load(int3(0, 0, 0));
        float _249 = _247.x - (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
        float _250 = (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _249;
        _254 = _250;
      } else {
        _254 = (PostProcess_000.PostProcessConstant_Z_000[5].x);
      }
      float _255 = _243.x - (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
      float _256 = (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _255;
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
      float _279 = _278 * _205;
      float4 _280 = t2.SampleLevel(s2, float2(_234, _235), 0.0f);
      if (_155) {
        float4 _284 = t7.Load(int3(0, 0, 0));
        float _286 = _284.x - (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
        float _287 = (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _286;
        _291 = _287;
      } else {
        _291 = (PostProcess_000.PostProcessConstant_Z_000[5].x);
      }
      float _292 = _280.x - (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][2].z);
      float _293 = (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][2].w) / _292;
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
      float _316 = _315 * _205;
      float _317 = abs(_279);
      float _318 = _317 / (PostProcess_000.PostProcessConstant_Z_000[6].x);
      float _319 = ceil(_318);
      float _320 = saturate(_319);
      float _321 = _239.x - _134;
      float _322 = _320 * _321;
      float _323 = _322 + _134;
      float _324 = abs(_316);
      float _325 = _324 / (PostProcess_000.PostProcessConstant_Z_000[6].x);
      float _326 = ceil(_325);
      float _327 = saturate(_326);
      float _328 = _241.z - _136;
      float _329 = _327 * _328;
      float _330 = _329 + _136;
      _520 = _323;
      _521 = _135;
      _522 = _330;
    } else {
      _520 = _134;
      _521 = _135;
      _522 = _136;
    }
  } else {
    int _333 = asint((User_000.UserConstant_Z_000[3].y));
    bool _334 = ((int)_333 > (int)0);
    if (_334) {
      float _336 = _33.x + TEXCOORD.x;
      float _337 = _43 + TEXCOORD.y;
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
      float _369 = _340.x - _134;
      float _370 = _340.y - _135;
      float _371 = _340.z - _136;
      float _372 = _371 + _368;
      float _373 = _369 * _340.w;
      float _374 = _370 * _340.w;
      float _375 = _372 * _340.w;
      float _376 = _373 + _134;
      float _377 = _374 + _135;
      float _378 = _375 + _136;
      _520 = _376;
      _521 = _377;
      _522 = _378;
    } else {
      int _381 = asint((User_000.UserConstant_Z_000[3].x));
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
        float _418 = (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][8].x) * _396;
        float _419 = mad(_397, (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][8].y), _418);
        float _420 = mad(_392.x, (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][8].z), _419);
        float _421 = _420 + (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][8].w);
        float _422 = (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][9].x) * _396;
        float _423 = mad(_397, (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][9].y), _422);
        float _424 = mad(_392.x, (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][9].z), _423);
        float _425 = _424 + (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][9].w);
        float _426 = (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][10].x) * _396;
        float _427 = mad(_397, (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][10].y), _426);
        float _428 = mad(_392.x, (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][10].z), _427);
        float _429 = _428 + (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][10].w);
        float _430 = (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][11].x) * _396;
        float _431 = mad(_397, (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][11].y), _430);
        float _432 = mad(_392.x, (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][11].z), _431);
        float _433 = _432 + (Global_000.GlobalCB_Z_2720.GlobalCB_Z__ProjConstant_Z_000[0][11].w);
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
      float _509 = _487.x - _134;
      float _510 = _487.y - _135;
      float _511 = _487.z - _136;
      float _512 = _511 + _506;
      float _513 = _508 * _509;
      float _514 = _508 * _510;
      float _515 = _512 * _508;
      float _516 = _513 + _134;
      float _517 = _514 + _135;
      float _518 = _515 + _136;
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
  float _543 = _53 * 2.0f;
  float _544 = _54 * 2.0f;
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
  float _578 = _572 * 335.718017578125f;
  float _579 = _573 * 335.718017578125f;
  float _580 = _574 * 335.718017578125f;
  float _581 = _578 + 1.0f;
  float _582 = _579 + 1.0f;
  float _583 = _580 + 1.0f;
  float _584 = log2(_581);
  float _585 = log2(_582);
  float _586 = log2(_583);
  float _587 = (PostProcess_000.PostProcessConstant_Z_320[0].x) * 0.07434873282909393f;
  float _588 = _587 * _584;
  float _589 = _587 * _585;
  float _590 = _586 * _587;
  float _591 = _588 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _592 = _589 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _593 = _590 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float4 _596 = t3.Sample(s3, float3(_591, _592, _593));
  float _600 = _596.x * 13.450128555297852f;
  float _601 = _596.y * 13.450128555297852f;
  float _602 = _596.z * 13.450128555297852f;
  float _603 = exp2(_600);
  float _604 = exp2(_601);
  float _605 = exp2(_602);
  float _606 = _603 + -1.0f;
  float _607 = _604 + -1.0f;
  float _608 = _605 + -1.0f;
  float _609 = _606 * 0.0029786902014166117f;
  float _610 = _607 * 0.0029786902014166117f;
  float _611 = _608 * 0.0029786902014166117f;
  float3 apt_scaled_lut_output = APTApplyPostProcessLUTScaling(
      float3(_578 * 0.0029786902014166117f, _579 * 0.0029786902014166117f, _580 * 0.0029786902014166117f),
      float3(_609 * (User_000.UserConstant_Z_000[4].x), _610 * (User_000.UserConstant_Z_000[4].y), _611 * (User_000.UserConstant_Z_000[4].z)),
      t3,
      s3,
      PostProcess_000.PostProcessConstant_Z_320[0].x,
      PostProcess_000.PostProcessConstant_Z_320[0].y,
      User_000.UserConstant_Z_000[4].rgb);
  float _618 = apt_scaled_lut_output.x;
  float _619 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 2.0f;
  float _620 = log2(_618);
  float _621 = _619 * _620;
  float _622 = exp2(_621);
  float _623 = _622 + -1.0f;
  float _624 = _618 + -1.0f;
  float _625 = _623 / _624;
  bool _626 = !(_618 == 1.0f);
  float _627 = _625 + -1.0f;
  float _628 = _627 / _625;
  float _629 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _630 = _629 / _619;
  float _631 = select(_626, _628, _630);
  float _632 = apt_scaled_lut_output.y;
  float _633 = log2(_632);
  float _634 = _633 * _619;
  float _635 = exp2(_634);
  float _636 = _635 + -1.0f;
  float _637 = _632 + -1.0f;
  float _638 = _636 / _637;
  bool _639 = !(_632 == 1.0f);
  float _640 = _638 + -1.0f;
  float _641 = _640 / _638;
  float _642 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _643 = _642 / _619;
  float _644 = select(_639, _641, _643);
  float _645 = apt_scaled_lut_output.z;
  float _646 = log2(_645);
  float _647 = _646 * _619;
  float _648 = exp2(_647);
  float _649 = _648 + -1.0f;
  float _650 = _645 + -1.0f;
  float _651 = _649 / _650;
  bool _652 = !(_645 == 1.0f);
  float _653 = _651 + -1.0f;
  float _654 = _653 / _651;
  float _655 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _656 = _655 / _619;
  float _657 = select(_652, _654, _656);
  float3 apt_post_process_output = APTApplyPostProcessToneMap(
      float3(_618, _632, _645),
      float3(_631, _644, _657),
      true);
  float _658 = apt_post_process_output.x;
  float _659 = apt_post_process_output.y;
  float _660 = apt_post_process_output.z;
  float _661 = log2(_658);
  float _662 = log2(_659);
  float _663 = log2(_660);
  float _664 = _661 * 0.4166666567325592f;
  float _665 = _662 * 0.4166666567325592f;
  float _666 = _663 * 0.4166666567325592f;
  float _667 = exp2(_664);
  float _668 = exp2(_665);
  float _669 = exp2(_666);
  float _670 = _667 * 1.0549999475479126f;
  float _671 = _668 * 1.0549999475479126f;
  float _672 = _669 * 1.0549999475479126f;
  float _673 = _670 + -0.054999999701976776f;
  float _674 = _671 + -0.054999999701976776f;
  float _675 = _672 + -0.054999999701976776f;
  float _676 = _658 * 12.920000076293945f;
  float _677 = _659 * 12.920000076293945f;
  float _678 = _660 * 12.920000076293945f;
  bool _679 = (_658 <= 0.0031308000907301903f);
  bool _680 = (_659 <= 0.0031308000907301903f);
  bool _681 = (_660 <= 0.0031308000907301903f);
  float _682 = select(_679, _676, _673);
  float _683 = select(_680, _677, _674);
  float _684 = select(_681, _678, _675);
  float _685 = log2(_682);
  float _686 = log2(_683);
  float _687 = log2(_684);
  float _688 = floor(_685);
  float _689 = floor(_686);
  float _690 = floor(_687);
  float _691 = _688 + -6.0f;
  float _692 = _689 + -6.0f;
  float _693 = _690 + -5.0f;
  float _694 = exp2(_691);
  float _695 = exp2(_692);
  float _696 = exp2(_693);
  bool _697 = (_682 <= 0.0f);
  bool _698 = (_683 <= 0.0f);
  bool _699 = (_684 <= 0.0f);
  float _700 = select(_697, 0.0f, _694);
  float _701 = select(_698, 0.0f, _695);
  float _702 = select(_699, 0.0f, _696);
  int _705 = asint((Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[1].w));
  uint _706 = uint(SV_Position.x);
  uint _707 = uint(SV_Position.y);
  int _708 = _706 & 63;
  int _709 = _707 & 63;
  float4 _711 = t1.Load(int4(_708, _709, _705, 0));
  float4 _714 = t6.Load(int4(_708, _709, _705, 0));
  float _717 = _711.x * _700;
  float _718 = _714.x * _701;
  float _719 = _714.y * _702;
  float _720 = _717 + _682;
  float _721 = _718 + _683;
  float _722 = _719 + _684;
  SV_Target.x = _720;
  SV_Target.y = _721;
  SV_Target.z = _722;
  SV_Target.w = _131.w;
  return SV_Target;
}
