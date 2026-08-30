#include "../common.hlsli"

Texture2D<float4> sDiffuse : register(t0);

Texture2DArray<float4> sBlueNoiseR8 : register(t1);

cbuffer CBufferGlobalConstant_Z : register(b0) {
  struct StructGlobalConstant_Z {
    float4 c[174];
  } Global : packoffset(c000.x);
};

cbuffer CBufferRenderStateConstant_Z : register(b1) {
  struct StructRenderStateConstant_Z {
    float AlphaRef;
    float NoOmni;
  } RenderState : packoffset(c000.x);
};

cbuffer CBufferObjectConstant_Z : register(b2) {
  struct StructObjectConstant_Z {
    float4 c[16];
  } Object[1] : packoffset(c000.x);
};

SamplerState sMaterialSampler : register(s0);

float4 main(
  linear float4 COLOR : COLOR,
  linear float4 TEXCOORD : TEXCOORD,
  noperspective float4 SV_Position : SV_Position,
  nointerpolation uint2 INSTANCE_INDEXES : INSTANCE_INDEXES
) : SV_Target {
  float4 SV_Target;
  float4 _15 = sDiffuse.Sample(sMaterialSampler, float2(TEXCOORD.x, TEXCOORD.y));
  float _20 = _15.x * COLOR.x;
  float _21 = _15.y * COLOR.y;
  float _22 = _15.z * COLOR.z;
  float _23 = _15.w * COLOR.w;
  float _28 = _20 * (Object[0].c[4].x);
  float _29 = _21 * (Object[0].c[4].y);
  float _30 = _22 * (Object[0].c[4].z);
  float _35 = _28 + (Object[0].c[5].x);
  float _36 = _29 + (Object[0].c[5].y);
  float _37 = _30 + (Object[0].c[5].z);
  float _39 = _23 * (Object[0].c[5].w);
  bool _42 = !(_39 <= RenderState.AlphaRef);
  float _100;
  float _101;
  float _102;
  if (!_42) {
    if (true) discard;
  }
  int _47 = asint((Global.c[1].x));
  int _48 = _47 & 1792;
  bool _49 = ((uint)_48 > (uint)1024);
  if (_49) {
    int _51 = _47 & 1;
    bool _52 = (_51 == 0);
    uint _53 = uint(SV_Position.x);
    uint _54 = uint(SV_Position.y);
    int _55 = _53 & 63;
    int _56 = _54 & 63;
    float4 _57 = sBlueNoiseR8.Load(int4(_55, _56, 0, 0));
    bool _59 = (_35 > 0.0f);
    bool _60 = (_36 > 0.0f);
    bool _61 = (_37 > 0.0f);
    float _62 = float((bool)_59);
    float _63 = float((bool)_60);
    float _64 = float((bool)_61);
    if (!_52) {
      float _66 = log2(_35);
      float _67 = log2(_36);
      float _68 = log2(_37);
      float _69 = floor(_66);
      float _70 = floor(_67);
      float _71 = floor(_68);
      float _72 = _69 + -6.0f;
      float _73 = _70 + -6.0f;
      float _74 = _71 + -5.0f;
      float _75 = exp2(_72);
      float _76 = exp2(_73);
      float _77 = exp2(_74);
      float _78 = _75 * _57.x;
      float _79 = _75 - _78;
      float _80 = _79 * _62;
      float _81 = _76 * _63;
      float _82 = _81 * _57.x;
      float _83 = _77 * _64;
      float _84 = _83 * _57.x;
      float _85 = _80 + _35;
      float _86 = _82 + _36;
      float _87 = _84 + _37;
      _100 = _85;
      _101 = _86;
      _102 = _87;
    } else {
      float _89 = _57.x * 0.003921568859368563f;
      float _90 = 0.003921568859368563f - _89;
      float _91 = _90 * _62;
      float _92 = _63 * 0.003921568859368563f;
      float _93 = _92 * _57.x;
      float _94 = _64 * 0.003921568859368563f;
      float _95 = _94 * _57.x;
      float _96 = _91 + _35;
      float _97 = _93 + _36;
      float _98 = _95 + _37;
      _100 = _96;
      _101 = _97;
      _102 = _98;
    }
  } else {
    _100 = _35;
    _101 = _36;
    _102 = _37;
  }
  SV_Target.rgb = APTScaleUIEncoded(float3(_100, _101, _102));
  SV_Target.w = _39;
  return SV_Target;
}
