#include "../ui.hlsli"

Texture2D<float4> t1 : register(t1);

Texture2D<float4> t10 : register(t10);

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

cbuffer cb12 : register(b12) {
  float cb12_007w : packoffset(c007.w);
  float cb12_008w : packoffset(c008.w);
  float cb12_009w : packoffset(c009.w);
  float cb12_011x : packoffset(c011.x);
  float cb12_011y : packoffset(c011.y);
};

cbuffer cb13 : register(b13) {
  float cb13_003y : packoffset(c003.y);
  float cb13_005x : packoffset(c005.x);
  float cb13_005z : packoffset(c005.z);
};

SamplerState s0 : register(s0);

SamplerState s3 : register(s3);

float4 main(
  linear float4 TEXCOORD : TEXCOORD,
  linear float2 TEXCOORD_1 : TEXCOORD1,
  linear float4 TEXCOORD_2 : TEXCOORD2
) : SV_Target {
  float4 SV_Target = 0;
  float4 _22 = t1.Sample(s0, float2(TEXCOORD_1.x, TEXCOORD_1.y));
  float _27 = TEXCOORD_2.x / TEXCOORD_2.w;
  float _28 = TEXCOORD_2.y / TEXCOORD_2.w;
  float _32 = cbufGlobal_128.x * _27;
  float _33 = cbufGlobal_128.y * _28;
  float _36 = _32 + cbufGlobal_128.z;
  float _37 = _33 + cbufGlobal_128.w;
  float4 _42 = t10.Sample(s3, float2(_36, _37));
  bool _44 = (cb12_009w < _42.x);
  float _50;
  if (_44) {
    float _48 = cb13_005z * _22.w;
    _50 = _48;
  } else {
    _50 = _22.w;
  }
  float _51 = ddx_coarse(TEXCOORD_1.x);
  float _52 = ddy_coarse(TEXCOORD_1.x);
  float _56 = cb12_011x * _51;
  float _57 = cb12_011y * _52;
  float _58 = _56 * _56;
  float _59 = _57 * _57;
  float _60 = _58 + _59;
  float _61 = sqrt(_60);
  float _64 = cb13_005x * 0.5f;
  float _65 = _64 * _61;
  float _68 = _64 + cb12_007w;
  float _69 = _68 * _61;
  float _70 = TEXCOORD_1.x + -0.5f;
  float _71 = TEXCOORD_1.y + -0.5f;
  float _72 = _70 * _70;
  float _73 = _71 * _71;
  float _74 = _73 + _72;
  float _75 = sqrt(_74);
  float _76 = _75 + -0.5f;
  float _77 = _76 + _69;
  float _78 = abs(_77);
  float _79 = _78 - _65;
  float _80 = max(0.0f, _79);
  float _81 = cb12_007w * _61;
  float _82 = _80 / _81;
  float _83 = saturate(_82);
  float _84 = 1.0f - _83;
  bool _87 = (_84 < cb13_003y);
  if (_87) {
    if (true) discard;
  }
  float _90 = _22.x * TEXCOORD.x;
  float _91 = _22.y * TEXCOORD.y;
  float _92 = _22.z * TEXCOORD.z;
  float _93 = _50 * TEXCOORD.w;
  float _94 = dot(float3(_90, _91, _92), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  float _97 = _94 - _90;
  float _98 = _94 - _91;
  float _99 = _94 - _92;
  float _100 = cbufGlobal_288 * _97;
  float _101 = cbufGlobal_288 * _98;
  float _102 = cbufGlobal_288 * _99;
  float _103 = _100 + _90;
  float _104 = _101 + _91;
  float _105 = _102 + _92;
  float _106 = _84 * _93;
  float _109 = _106 * cb12_008w;
  float _110 = _109 * _103;
  float _111 = _109 * _104;
  float _112 = _109 * _105;
  SV_Target.x = _110;
  SV_Target.y = _111;
  SV_Target.z = _112;
  SV_Target.w = _106;
  if (GhostIsUIOverrideActive()) {
    SV_Target.rgb = GhostRenderUI(float3(_103, _104, _105) * _106, _106);
  }
  return SV_Target;
}
