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
  SV_Target.x = 0.0f;
  SV_Target.y = 0.0f;
  SV_Target.z = 0.0f;
  SV_Target.w = 0.0f;
  uint _26 = (uint)(RootSrtCbv_000) + 32u;
  uint _27 = (uint)(RootSrtCbv_000) + 96u;
  uint _28 = (uint)(RootSrtCbv_000) + 296u;
  float4 _29 = asfloat(t1_space1.Load4(_28));
  uint _31 = (uint)(RootSrtCbv_000) + 300u;
  float4 _32 = asfloat(t1_space1.Load4(_31));
  uint _34 = (uint)(RootSrtCbv_000) + 304u;
  float4 _35 = asfloat(t1_space1.Load4(_34));
  uint _40 = (uint)(RootSrtCbv_000) + 320u;
  float4 _41 = asfloat(t1_space1.Load4(_40));
  uint _44 = (uint)(RootSrtCbv_000) + 328u;
  float4 _45 = asfloat(t1_space1.Load4(_44));
  uint _50 = (uint)(RootSrtCbv_000) + 344u;
  float4 _51 = asfloat(t1_space1.Load4(_50));
  float _53 = min(TEXCOORD_2.x, TEXCOORD_2.y);
  float _54 = saturate(_53);
  float _55 = max(TEXCOORD_2.z, _54);
  float _56 = _41.x * TEXCOORD_3.x;
  float _57 = _41.y * TEXCOORD_3.y;
  float _58 = saturate(_56);
  float _59 = saturate(_57);
  float _60 = min(_29.x, _32.x);
  float _61 = max(_29.x, _32.x);
  float _62 = _61 - _60;
  float _63 = 0.5f - _61;
  float _64 = abs(_63);
  float _65 = 0.5f - _64;
  float _66 = min(0.05000000074505806f, _65);
  float _67 = min(_66, _62);
  bool _68 = (_61 < _58);
  float _69 = select(_68, 0.0f, 1.0f);
  float _70 = _58 - _61;
  float _71 = _70 + _67;
  float _72 = _67 * 2.0f;
  float _73 = _71 / _72;
  float _74 = 1.0f - _73;
  float _75 = saturate(_74);
  bool _76 = (_67 <= 0.0f);
  float _77 = select(_76, _69, _75);
  float _78 = 0.5f - _60;
  float _79 = abs(_78);
  float _80 = 0.5f - _79;
  float _81 = min(0.05000000074505806f, _80);
  float _82 = min(_81, _62);
  bool _83 = (_58 < _60);
  float _84 = select(_83, 0.0f, 1.0f);
  float _85 = _60 - _58;
  float _86 = _85 + _82;
  float _87 = _82 * 2.0f;
  float _88 = _86 / _87;
  float _89 = 1.0f - _88;
  float _90 = saturate(_89);
  bool _91 = (_82 <= 0.0f);
  float _92 = select(_91, _84, _90);
  float _93 = min(_92, _77);
  float _94 = _93 * _55;
  float _95 = _58 * _35.x;
  float _96 = _59 * _35.y;
  float _97 = _95 + _35.z;
  float _98 = _96 + _35.w;
  int4 _99 = asint(t1_space1.Load4(_27));
  Texture2D<float4> _102 = ResourceDescriptorHeap[(uint)(_99.x)];
  float4 _104 = _102.Sample(s1, float2(_97, _98));
  int4 _106 = asint(t1_space1.Load4(RootSrtCbv_000));
  Texture2D<float4> _109 = ResourceDescriptorHeap[(uint)(_106.x)];
  float4 _111 = _109.Sample(s0, float2(TEXCOORD.x, TEXCOORD.y));
  int4 _113 = asint(t1_space1.Load4(_26));
  Texture2D<float4> _116 = ResourceDescriptorHeap[(uint)(_113.x)];
  float4 _117 = _116.Sample(s0, float2(TEXCOORD.x, TEXCOORD.y));
  bool _122 = (TEXCOORD_1.w > 0.5f);
  float _132;
  float _196;
  float _197;
  float _198;
  float _199;
  if (_122) {
    uint _124 = (uint)(RootSrtCbv_000) + 64u;
    int4 _125 = asint(t1_space1.Load4(_124));
    Texture2D<float4> _128 = ResourceDescriptorHeap[(uint)(_125.x)];
    float4 _129 = _128.Sample(s0, float2(TEXCOORD.x, TEXCOORD.y));
    _132 = _129.w;
  } else {
    _132 = _111.w;
  }
  float _133 = ddx_coarse(TEXCOORD.x);
  float _134 = ddy_coarse(TEXCOORD.x);
  float _135 = _133 * _133;
  float _136 = _134 * _134;
  float _137 = _136 + _135;
  float _138 = sqrt(_137);
  float _139 = ddx_coarse(TEXCOORD.y);
  float _140 = ddy_coarse(TEXCOORD.y);
  float _141 = _139 * _139;
  float _142 = _140 * _140;
  float _143 = _142 + _141;
  float _144 = sqrt(_143);
  float _145 = _144 * _138;
  float _146 = sqrt(_145);
  float _147 = _146 * 0.5f;
  bool _148 = (TEXCOORD_1.z > 0.0f);
  float _149 = _147 / TEXCOORD_1.z;
  float _150 = select(_148, _149, 0.0f);
  float _151 = _150 + 0.5f;
  float _152 = saturate(_151);
  float _153 = 0.5f - _150;
  float _154 = saturate(_153);
  float _155 = _152 - _154;
  float _156 = _132 - _154;
  float _157 = _156 / _155;
  float _158 = saturate(_157);
  float _159 = _158 * 2.0f;
  float _160 = 3.0f - _159;
  float _161 = _158 * _158;
  float _162 = _161 * _160;
  float _163 = 1.0f - _162;
  float _164 = _163 * TEXCOORD_1.y;
  float _165 = _164 + _162;
  float _166 = _165 * COLOR.w;
  bool _167 = !(_51.x >= 0.003921568859368563f);
  if (!_167) {
    float _169 = _51.x * -0.4000000059604645f;
    float _170 = _169 + 0.6000000238418579f;
    float _171 = saturate(_170);
    float _172 = _169 + 0.4000000059604645f;
    float _173 = saturate(_172);
    float _174 = _171 - _173;
    float _175 = _132 - _173;
    float _176 = _175 / _174;
    float _177 = saturate(_176);
    float _178 = _177 * 2.0f;
    float _179 = 3.0f - _178;
    float _180 = _177 * _177;
    float _181 = _180 * _45.w;
    float _182 = _181 * _179;
    float _183 = COLOR.x - _45.x;
    float _184 = COLOR.y - _45.y;
    float _185 = COLOR.z - _45.z;
    float _186 = COLOR.w - _182;
    float _187 = _165 * _183;
    float _188 = _165 * _184;
    float _189 = _165 * _185;
    float _190 = _186 * _165;
    float _191 = _187 + _45.x;
    float _192 = _188 + _45.y;
    float _193 = _189 + _45.z;
    float _194 = _190 + _182;
    _196 = _191;
    _197 = _192;
    _198 = _193;
    _199 = _194;
  } else {
    _196 = COLOR.x;
    _197 = COLOR.y;
    _198 = COLOR.z;
    _199 = _166;
  }
  float _200 = _117.x * COLOR.x;
  float _201 = _117.y * COLOR.y;
  float _202 = _117.z * COLOR.z;
  float _203 = _117.w * COLOR.w;
  float _204 = _200 - _196;
  float _205 = _201 - _197;
  float _206 = _202 - _198;
  float _207 = _203 - _199;
  float _208 = _204 * TEXCOORD_1.x;
  float _209 = _205 * TEXCOORD_1.x;
  float _210 = _206 * TEXCOORD_1.x;
  float _211 = _207 * TEXCOORD_1.x;
  float _212 = _208 + _196;
  float _213 = _209 + _197;
  float _214 = _210 + _198;
  float _215 = _211 + _199;
  float _216 = _94 * _104.w;
  float _217 = _216 * _215;
  float _220 = cbufGlobal_264 * _212;
  float _221 = cbufGlobal_264 * _213;
  float _222 = _214 * cbufGlobal_264;
  SV_Target.x = _220;
  SV_Target.y = _221;
  SV_Target.z = _222;
  SV_Target.w = _217;
  if (GhostIsUIOverrideActive()) {
    SV_Target.rgb = GhostRenderUI(float3(_212, _213, _214), 1.f);
  }
  return SV_Target;
}
