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

Texture2DArray<float4> t2 : register(t2);

Texture2D<float4> t0 : register(t0);

Texture3D<float4> t3 : register(t3);

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

SamplerState s3 : register(s3);

SamplerState s8 : register(s8);

SamplerState s14 : register(s14);

float4 main(
  linear float4 TEXCOORD : TEXCOORD,
  noperspective float4 SV_Position : SV_Position
) : SV_Target {
  float4 SV_Target;
  float4 _28 = t14.Sample(s14, float2(TEXCOORD.x, TEXCOORD.y));
  float4 _34 = t16.Sample(s0, float2(TEXCOORD.z, TEXCOORD.w));
  float _37 = _34.y * 0.10000000149011612f;
  float _38 = _37 + _28.y;
  float _39 = _34.y * 0.5f;
  float _40 = _39 + _28.z;
  float _41 = exp2(_40);
  float _42 = _41 + -1.0f;
  float _45 = (PostProcess_000.PostProcessConstant_Z_000[11].y) * _42;
  float _46 = _45 + 1.0f;
  float _47 = log2(_46);
  float _48 = _28.x + TEXCOORD.z;
  float _49 = _38 + TEXCOORD.w;
  float _50 = _28.x + TEXCOORD.x;
  float _51 = _38 + TEXCOORD.y;
  float _52 = _47 + 1.0f;
  float _53 = log2(_52);
  float _57 = 0.5f - (PostProcess_000.PostProcessConstant_Z_000[19].x);
  float _58 = 0.5f - (PostProcess_000.PostProcessConstant_Z_000[19].y);
  float _59 = _57 + _48;
  float _60 = _58 + _49;
  float _61 = _59 * 2.0f;
  float _62 = _60 * 2.0f;
  float _63 = _61 + -1.0f;
  float _64 = _62 + -1.0f;
  float _68 = _64 * (Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[51].y);
  float _69 = abs(_63);
  float _70 = abs(_64);
  float _72 = (PostProcess_000.PostProcessConstant_Z_000[19].z) * 2.0f;
  float _73 = _72 + -1.0f;
  float _74 = _69 - _73;
  float _75 = _70 - _73;
  float _76 = saturate(_74);
  float _77 = saturate(_75);
  float _78 = _76 * (Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[51].x);
  float _79 = _78 * _63;
  float _80 = _68 * _77;
  float _81 = _79 * _79;
  float _82 = _80 * _80;
  float _83 = _81 + _82;
  float _84 = sqrt(_83);
  float _87 = _57 + _50;
  float _88 = _58 + _51;
  float _89 = _87 * 2.0f;
  float _90 = _89 + -1.0f;
  float _91 = _88 * 1.125f;
  float _92 = _91 + -0.5625f;
  float _93 = _90 * _90;
  float _94 = _92 * _92;
  float _95 = _93 + _94;
  float _96 = sqrt(_95);
  float _97 = _96 * 0.8715755343437195f;
  float _98 = _97 * _97;
  float _99 = _98 + -0.15000000596046448f;
  float _100 = _99 * 1.8181819915771484f;
  float _101 = saturate(_100);
  float _102 = _101 * 2.0f;
  float _103 = 3.0f - _102;
  float _104 = (PostProcess_000.PostProcessConstant_Z_000[2].w) * _84;
  float _105 = _101 * _101;
  float _106 = _105 * _104;
  float _107 = _106 * _98;
  float _108 = _107 * _103;
  float _110 = (PostProcess_000.PostProcessConstant_Z_000[2].z) * _79;
  float _111 = (PostProcess_000.PostProcessConstant_Z_000[2].z) * _80;
  float _112 = _111 + _49;
  float _113 = _48 - _110;
  float _114 = _34.x * 0.010840999893844128f;
  float _115 = _114 + _48;
  float _116 = _115 + _110;
  float _117 = _49 + _114;
  float _118 = _117 - _111;
  float _119 = max(_108, _53);
  float4 _122 = t0.SampleLevel(s0, float2(_116, _112), _119);
  float4 _124 = t0.SampleLevel(s0, float2(_113, _118), _119);
  float4 _126 = t0.SampleLevel(s0, float2(_48, _49), _119);
  float _129 = max(_122.x, 0.0f);
  float _130 = max(_124.y, 0.0f);
  float _131 = max(_126.z, 0.0f);
  float4 _133 = t12.SampleLevel(s0, float2(_48, _49), 0.0f);
  float4 _139 = t8.Sample(s8, float2(_50, _51));
  int _145 = asint((User_000.UserConstant_Z_000[3].z));
  bool _146 = ((int)_145 > (int)0);
  float _175;
  float _176;
  float _177;
  float _182;
  float _183;
  float _184;
  float _213;
  float _214;
  float _215;
  float _220;
  float _221;
  float _222;
  if (!_146) {
    bool _150 = !((PostProcess_000.PostProcessConstant_Z_000[17].z) >= -1.0f);
    float _154 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _139.x;
    float _155 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _139.y;
    float _156 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _139.z;
    float _157 = _154 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    float _158 = _155 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    float _159 = _156 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    if (!_150) {
      float _161 = _157 * _133.x;
      float _162 = _158 * _133.y;
      float _163 = _159 * _133.z;
      _175 = _161;
      _176 = _162;
      _177 = _163;
    } else {
      float _165 = saturate(_157);
      float _166 = saturate(_158);
      float _167 = saturate(_159);
      float _168 = _133.x - _129;
      float _169 = _133.y - _130;
      float _170 = _133.z - _131;
      float _171 = _165 * _168;
      float _172 = _166 * _169;
      float _173 = _167 * _170;
      _175 = _171;
      _176 = _172;
      _177 = _173;
    }
    float _178 = _175 + _129;
    float _179 = _176 + _130;
    float _180 = _177 + _131;
    _182 = _178;
    _183 = _179;
    _184 = _180;
  } else {
    _182 = _129;
    _183 = _130;
    _184 = _131;
  }
  if (_146) {
    bool _188 = !((PostProcess_000.PostProcessConstant_Z_000[17].z) >= -1.0f);
    float _192 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _139.x;
    float _193 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _139.y;
    float _194 = (PostProcess_000.PostProcessConstant_Z_000[4].w) * _139.z;
    float _195 = _192 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    float _196 = _193 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    float _197 = _194 + (PostProcess_000.PostProcessConstant_Z_000[4].z);
    if (!_188) {
      float _199 = _195 * _133.x;
      float _200 = _196 * _133.y;
      float _201 = _197 * _133.z;
      _213 = _199;
      _214 = _200;
      _215 = _201;
    } else {
      float _203 = saturate(_195);
      float _204 = saturate(_196);
      float _205 = saturate(_197);
      float _206 = _133.x - _182;
      float _207 = _133.y - _183;
      float _208 = _133.z - _184;
      float _209 = _203 * _206;
      float _210 = _204 * _207;
      float _211 = _205 * _208;
      _213 = _209;
      _214 = _210;
      _215 = _211;
    }
    float _216 = _213 + _182;
    float _217 = _214 + _183;
    float _218 = _215 + _184;
    _220 = _216;
    _221 = _217;
    _222 = _218;
  } else {
    _220 = _182;
    _221 = _183;
    _222 = _184;
  }
  float4 _226 = t17.Load(int3(0, 0, 0));
  float _235 = (Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[87].y) * 335.718017578125f;
  float _236 = _226.x * _235;
  float _237 = _236 * _220;
  float _238 = _237 * (PostProcess_000.PostProcessConstant_Z_000[14].x);
  float _239 = _236 * _221;
  float _240 = _239 * (PostProcess_000.PostProcessConstant_Z_000[14].y);
  float _241 = _236 * _222;
  float _242 = _241 * (PostProcess_000.PostProcessConstant_Z_000[14].z);
  float _243 = _238 + 1.0f;
  float _244 = _240 + 1.0f;
  float _245 = _242 + 1.0f;
  float _246 = log2(_243);
  float _247 = log2(_244);
  float _248 = log2(_245);
  float _249 = (PostProcess_000.PostProcessConstant_Z_320[0].x) * 0.07434873282909393f;
  float _250 = _249 * _246;
  float _251 = _249 * _247;
  float _252 = _248 * _249;
  float _253 = _250 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _254 = _251 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float _255 = _252 + (PostProcess_000.PostProcessConstant_Z_320[0].y);
  float4 _258 = t3.Sample(s3, float3(_253, _254, _255));
  float _262 = _258.x * 13.450128555297852f;
  float _263 = _258.y * 13.450128555297852f;
  float _264 = _258.z * 13.450128555297852f;
  float _265 = exp2(_262);
  float _266 = exp2(_263);
  float _267 = exp2(_264);
  float _268 = _265 + -1.0f;
  float _269 = _266 + -1.0f;
  float _270 = _267 + -1.0f;
  float _271 = _268 * 0.0029786902014166117f;
  float _272 = _269 * 0.0029786902014166117f;
  float _273 = _270 * 0.0029786902014166117f;
  float3 apt_scaled_lut_output = APTApplyPostProcessLUT(
      float3(_238 * 0.0029786902014166117f, _240 * 0.0029786902014166117f, _242 * 0.0029786902014166117f),
      float3(_271 * (User_000.UserConstant_Z_000[4].x), _272 * (User_000.UserConstant_Z_000[4].y), _273 * (User_000.UserConstant_Z_000[4].z)),
      User_000.UserConstant_Z_000[4].rgb);
  apt_scaled_lut_output = APTApplyPerceptualFilmGrain(apt_scaled_lut_output, SV_Position.xy);
  float _280 = apt_scaled_lut_output.x;
  float _281 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 2.0f;
  float _282 = log2(_280);
  float _283 = _281 * _282;
  float _284 = exp2(_283);
  float _285 = _284 + -1.0f;
  float _286 = _280 + -1.0f;
  float _287 = _285 / _286;
  bool _288 = !(_280 == 1.0f);
  float _289 = _287 + -1.0f;
  float _290 = _289 / _287;
  float _291 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _292 = _291 / _281;
  float _293 = select(_288, _290, _292);
  float _294 = apt_scaled_lut_output.y;
  float _295 = log2(_294);
  float _296 = _295 * _281;
  float _297 = exp2(_296);
  float _298 = _297 + -1.0f;
  float _299 = _294 + -1.0f;
  float _300 = _298 / _299;
  bool _301 = !(_294 == 1.0f);
  float _302 = _300 + -1.0f;
  float _303 = _302 / _300;
  float _304 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _305 = _304 / _281;
  float _306 = select(_301, _303, _305);
  float _307 = apt_scaled_lut_output.z;
  float _308 = log2(_307);
  float _309 = _308 * _281;
  float _310 = exp2(_309);
  float _311 = _310 + -1.0f;
  float _312 = _307 + -1.0f;
  float _313 = _311 / _312;
  bool _314 = !(_307 == 1.0f);
  float _315 = _313 + -1.0f;
  float _316 = _315 / _313;
  float _317 = (PostProcess_000.PostProcessConstant_Z_000[17].y) + 1.0f;
  float _318 = _317 / _281;
  float _319 = select(_314, _316, _318);
  float3 apt_post_process_output = APTApplyPostProcessToneMap(
      float3(_280, _294, _307),
      float3(_293, _306, _319),
      true);
  float _320 = apt_post_process_output.x;
  float _321 = apt_post_process_output.y;
  float _322 = apt_post_process_output.z;
  float _323 = log2(_320);
  float _324 = log2(_321);
  float _325 = log2(_322);
  float _326 = _323 * 0.4166666567325592f;
  float _327 = _324 * 0.4166666567325592f;
  float _328 = _325 * 0.4166666567325592f;
  float _329 = exp2(_326);
  float _330 = exp2(_327);
  float _331 = exp2(_328);
  float _332 = _329 * 1.0549999475479126f;
  float _333 = _330 * 1.0549999475479126f;
  float _334 = _331 * 1.0549999475479126f;
  float _335 = _332 + -0.054999999701976776f;
  float _336 = _333 + -0.054999999701976776f;
  float _337 = _334 + -0.054999999701976776f;
  float _338 = _320 * 12.920000076293945f;
  float _339 = _321 * 12.920000076293945f;
  float _340 = _322 * 12.920000076293945f;
  bool _341 = (_320 <= 0.0031308000907301903f);
  bool _342 = (_321 <= 0.0031308000907301903f);
  bool _343 = (_322 <= 0.0031308000907301903f);
  float _344 = select(_341, _338, _335);
  float _345 = select(_342, _339, _336);
  float _346 = select(_343, _340, _337);
  float _347 = log2(_344);
  float _348 = log2(_345);
  float _349 = log2(_346);
  float _350 = floor(_347);
  float _351 = floor(_348);
  float _352 = floor(_349);
  float _353 = _350 + -6.0f;
  float _354 = _351 + -6.0f;
  float _355 = _352 + -5.0f;
  float _356 = exp2(_353);
  float _357 = exp2(_354);
  float _358 = exp2(_355);
  bool _359 = (_344 <= 0.0f);
  bool _360 = (_345 <= 0.0f);
  bool _361 = (_346 <= 0.0f);
  float _362 = select(_359, 0.0f, _356);
  float _363 = select(_360, 0.0f, _357);
  float _364 = select(_361, 0.0f, _358);
  int _367 = asint((Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[1].w));
  uint _368 = uint(SV_Position.x);
  uint _369 = uint(SV_Position.y);
  int _370 = _368 & 63;
  int _371 = _369 & 63;
  float4 _373 = t1.Load(int4(_370, _371, _367, 0));
  float4 _376 = t2.Load(int4(_370, _371, _367, 0));
  float _379 = _373.x * _362;
  float _380 = _376.x * _363;
  float _381 = _376.y * _364;
  float _382 = _379 + _344;
  float _383 = _380 + _345;
  float _384 = _381 + _346;
  SV_Target.x = _382;
  SV_Target.y = _383;
  SV_Target.z = _384;
  SV_Target.w = _126.w;
  return SV_Target;
}
