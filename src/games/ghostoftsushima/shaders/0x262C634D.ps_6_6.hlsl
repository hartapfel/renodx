#include "../ui.hlsli"

ByteAddressBuffer t1_space1 : register(t1, space1);

cbuffer cb14 : register(b14) {
  int RootSrtCbv_000 : packoffset(c000.x);
  int RootSrtCbv_004 : packoffset(c000.y);
};

cbuffer cb0 : register(b0) {
  float4 cbufGlobal_000[4] : packoffset(c000.x);
  float4 cbufGlobal_064[4] : packoffset(c004.x);
  float4 cbufGlobal_128 : packoffset(c008.x);
  float4 cbufGlobal_144 : packoffset(c009.x);
  float2 cbufGlobal_160 : packoffset(c010.x);
  float2 cbufGlobal_168 : packoffset(c010.z);
  float4 cbufGlobal_176 : packoffset(c011.x);
  float4 cbufGlobal_192 : packoffset(c012.x);
  float3 cbufGlobal_208 : packoffset(c013.x);
  float cbufGlobal_220 : packoffset(c013.w);
  float cbufGlobal_224 : packoffset(c014.x);
  float cbufGlobal_228 : packoffset(c014.y);
  float cbufGlobal_232 : packoffset(c014.z);
  float cbufGlobal_236 : packoffset(c014.w);
  float cbufGlobal_240 : packoffset(c015.x);
  float cbufGlobal_244 : packoffset(c015.y);
  float cbufGlobal_248 : packoffset(c015.z);
  float cbufGlobal_252 : packoffset(c015.w);
  float cbufGlobal_256 : packoffset(c016.x);
  float cbufGlobal_260 : packoffset(c016.y);
  float cbufGlobal_264 : packoffset(c016.z);
  float cbufGlobal_268 : packoffset(c016.w);
  float2 cbufGlobal_272 : packoffset(c017.x);
  int cbufGlobal_280 : packoffset(c017.z);
  float cbufGlobal_284 : packoffset(c017.w);
  float cbufGlobal_288 : packoffset(c018.x);
  float3 cbufGlobal_292 : packoffset(c018.y);
};

SamplerState s0 : register(s0);

SamplerState s1 : register(s1);

float4 main(
  linear float3 TEXCOORD_3 : TEXCOORD3,
  linear float2 TEXCOORD : TEXCOORD,
  linear float4 COLOR : COLOR,
  nointerpolation float4 TEXCOORD_1 : TEXCOORD1,
  linear float3 TEXCOORD_2 : TEXCOORD2,
  noperspective float4 SV_Position : SV_Position
) : SV_Target {
  float4 SV_Target = 0;
  uint _27 = (uint)(RootSrtCbv_000) + 32u;
  uint _28 = (uint)(RootSrtCbv_000) + 96u;
  uint _29 = (uint)(RootSrtCbv_000) + 224u;
  float4 _30 = asfloat(t1_space1.Load4(_29));
  uint _35 = (uint)(RootSrtCbv_000) + 240u;
  float4 _36 = asfloat(t1_space1.Load4(_35));
  uint _41 = (uint)(RootSrtCbv_000) + 296u;
  float4 _42 = asfloat(t1_space1.Load4(_41));
  uint _44 = (uint)(RootSrtCbv_000) + 300u;
  float4 _45 = asfloat(t1_space1.Load4(_44));
  uint _47 = (uint)(RootSrtCbv_000) + 304u;
  float4 _48 = asfloat(t1_space1.Load4(_47));
  uint _53 = (uint)(RootSrtCbv_000) + 320u;
  float4 _54 = asfloat(t1_space1.Load4(_53));
  uint _57 = (uint)(RootSrtCbv_000) + 328u;
  float4 _58 = asfloat(t1_space1.Load4(_57));
  uint _63 = (uint)(RootSrtCbv_000) + 344u;
  float4 _64 = asfloat(t1_space1.Load4(_63));
  uint _66 = (uint)(RootSrtCbv_000) + 356u;
  float4 _67 = asfloat(t1_space1.Load4(_66));
  float _72 = min(TEXCOORD_2.x, TEXCOORD_2.y);
  float _73 = saturate(_72);
  float _74 = max(TEXCOORD_2.z, _73);
  float _75 = _54.x * TEXCOORD_3.x;
  float _76 = _54.y * TEXCOORD_3.y;
  float _77 = saturate(_75);
  float _78 = saturate(_76);
  float _79 = min(_42.x, _45.x);
  float _80 = max(_42.x, _45.x);
  float _81 = _80 - _79;
  float _82 = 0.5f - _80;
  float _83 = abs(_82);
  float _84 = 0.5f - _83;
  float _85 = min(0.05000000074505806f, _84);
  float _86 = min(_85, _81);
  bool _87 = (_80 < _77);
  float _88 = select(_87, 0.0f, 1.0f);
  float _89 = _77 - _80;
  float _90 = _89 + _86;
  float _91 = _86 * 2.0f;
  float _92 = _90 / _91;
  float _93 = 1.0f - _92;
  float _94 = saturate(_93);
  bool _95 = (_86 <= 0.0f);
  float _96 = select(_95, _88, _94);
  float _97 = 0.5f - _79;
  float _98 = abs(_97);
  float _99 = 0.5f - _98;
  float _100 = min(0.05000000074505806f, _99);
  float _101 = min(_100, _81);
  bool _102 = (_77 < _79);
  float _103 = select(_102, 0.0f, 1.0f);
  float _104 = _79 - _77;
  float _105 = _104 + _101;
  float _106 = _101 * 2.0f;
  float _107 = _105 / _106;
  float _108 = 1.0f - _107;
  float _109 = saturate(_108);
  bool _110 = (_101 <= 0.0f);
  float _111 = select(_110, _103, _109);
  float _112 = min(_111, _96);
  float _113 = _112 * _74;
  float _114 = _77 * _48.x;
  float _115 = _78 * _48.y;
  float _116 = _114 + _48.z;
  float _117 = _115 + _48.w;
  int4 _118 = asint(t1_space1.Load4(_28));
  Texture2D<float4> _121 = ResourceDescriptorHeap[(uint)(_118.x)];
  float4 _123 = _121.Sample(s1, float2(_116, _117));
  int4 _125 = asint(t1_space1.Load4(RootSrtCbv_000));
  Texture2D<float4> _128 = ResourceDescriptorHeap[(uint)(_125.x)];
  float4 _130 = _128.Sample(s0, float2(TEXCOORD.x, TEXCOORD.y));
  int4 _132 = asint(t1_space1.Load4(_27));
  Texture2D<float4> _135 = ResourceDescriptorHeap[(uint)(_132.x)];
  float4 _136 = _135.Sample(s0, float2(TEXCOORD.x, TEXCOORD.y));
  bool _141 = (TEXCOORD_1.w > 0.5f);
  float _151;
  float _215;
  float _216;
  float _217;
  float _218;
  if (_141) {
    uint _143 = (uint)(RootSrtCbv_000) + 64u;
    int4 _144 = asint(t1_space1.Load4(_143));
    Texture2D<float4> _147 = ResourceDescriptorHeap[(uint)(_144.x)];
    float4 _148 = _147.Sample(s0, float2(TEXCOORD.x, TEXCOORD.y));
    _151 = _148.w;
  } else {
    _151 = _130.w;
  }
  float _152 = ddx_coarse(TEXCOORD.x);
  float _153 = ddy_coarse(TEXCOORD.x);
  float _154 = _152 * _152;
  float _155 = _153 * _153;
  float _156 = _155 + _154;
  float _157 = sqrt(_156);
  float _158 = ddx_coarse(TEXCOORD.y);
  float _159 = ddy_coarse(TEXCOORD.y);
  float _160 = _158 * _158;
  float _161 = _159 * _159;
  float _162 = _161 + _160;
  float _163 = sqrt(_162);
  float _164 = _163 * _157;
  float _165 = sqrt(_164);
  float _166 = _165 * 0.5f;
  bool _167 = (TEXCOORD_1.z > 0.0f);
  float _168 = _166 / TEXCOORD_1.z;
  float _169 = select(_167, _168, 0.0f);
  float _170 = _169 + 0.5f;
  float _171 = saturate(_170);
  float _172 = 0.5f - _169;
  float _173 = saturate(_172);
  float _174 = _171 - _173;
  float _175 = _151 - _173;
  float _176 = _175 / _174;
  float _177 = saturate(_176);
  float _178 = _177 * 2.0f;
  float _179 = 3.0f - _178;
  float _180 = _177 * _177;
  float _181 = _180 * _179;
  float _182 = 1.0f - _181;
  float _183 = _182 * TEXCOORD_1.y;
  float _184 = _183 + _181;
  float _185 = _184 * COLOR.w;
  bool _186 = !(_64.x >= 0.003921568859368563f);
  if (!_186) {
    float _188 = _64.x * -0.4000000059604645f;
    float _189 = _188 + 0.6000000238418579f;
    float _190 = saturate(_189);
    float _191 = _188 + 0.4000000059604645f;
    float _192 = saturate(_191);
    float _193 = _190 - _192;
    float _194 = _151 - _192;
    float _195 = _194 / _193;
    float _196 = saturate(_195);
    float _197 = _196 * 2.0f;
    float _198 = 3.0f - _197;
    float _199 = _196 * _196;
    float _200 = _199 * _58.w;
    float _201 = _200 * _198;
    float _202 = COLOR.x - _58.x;
    float _203 = COLOR.y - _58.y;
    float _204 = COLOR.z - _58.z;
    float _205 = COLOR.w - _201;
    float _206 = _184 * _202;
    float _207 = _184 * _203;
    float _208 = _184 * _204;
    float _209 = _205 * _184;
    float _210 = _206 + _58.x;
    float _211 = _207 + _58.y;
    float _212 = _208 + _58.z;
    float _213 = _209 + _201;
    _215 = _210;
    _216 = _211;
    _217 = _212;
    _218 = _213;
  } else {
    _215 = COLOR.x;
    _216 = COLOR.y;
    _217 = COLOR.z;
    _218 = _185;
  }
  float _219 = _136.x * COLOR.x;
  float _220 = _136.y * COLOR.y;
  float _221 = _136.z * COLOR.z;
  float _222 = _136.w * COLOR.w;
  float _223 = _219 - _215;
  float _224 = _220 - _216;
  float _225 = _221 - _217;
  float _226 = _222 - _218;
  float _227 = _223 * TEXCOORD_1.x;
  float _228 = _224 * TEXCOORD_1.x;
  float _229 = _225 * TEXCOORD_1.x;
  float _230 = _226 * TEXCOORD_1.x;
  float _231 = _227 + _215;
  float _232 = _228 + _216;
  float _233 = _229 + _217;
  float _234 = _230 + _218;
  float _235 = _113 * _123.w;
  float _236 = _235 * _234;
  float _239 = cbufGlobal_264 * _231;
  float _240 = cbufGlobal_264 * _232;
  float _241 = _233 * cbufGlobal_264;
  float _242 = _30.x * TEXCOORD_3.x;
  float _243 = mad(_30.y, TEXCOORD_3.y, _242);
  float _244 = mad(_30.z, TEXCOORD_3.z, _243);
  float _245 = _244 + _30.w;
  float _246 = _36.x * TEXCOORD_3.x;
  float _247 = mad(_36.y, TEXCOORD_3.y, _246);
  float _248 = mad(_36.z, TEXCOORD_3.z, _247);
  float _249 = _248 + _36.w;
  float _250 = dot(float2(_245, _249), float2(_67.x, _67.y));
  float _251 = _250 - _67.z;
  float _252 = _67.w - _67.z;
  float _253 = _251 / _252;
  float _254 = saturate(_253);
  float _255 = _236 * _254;
  SV_Target.x = _239;
  SV_Target.y = _240;
  SV_Target.z = _241;
  SV_Target.w = _255;
  if (GhostIsUIOverrideActive()) {
    SV_Target.rgb = GhostRenderUI(float3(_231, _232, _233), 1.f);
  }
  return SV_Target;
}
