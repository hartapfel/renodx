#include "../common.hlsli"

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

struct MaterialConstant_Z {
  float3 MaterialConstant_Z_000;
  float MaterialConstant_Z_012;
  float3 MaterialConstant_Z_016;
  float MaterialConstant_Z_028;
  float3 MaterialConstant_Z_032;
  float MaterialConstant_Z_044;
  float3 MaterialConstant_Z_048;
  int MaterialConstant_Z_060;
  float3 MaterialConstant_Z_064;
  int MaterialConstant_Z_076;
  float MaterialConstant_Z_080;
  float MaterialConstant_Z_084;
  float MaterialConstant_Z_088;
  float MaterialConstant_Z_092;
  float4 MaterialConstant_Z_096[6];
  float4 MaterialConstant_Z_192;
  float4 MaterialConstant_Z_208;
  float3 MaterialConstant_Z_224;
  int MaterialConstant_Z_236;
  int4 MaterialConstant_Z_240;
  float4 MaterialConstant_Z_256;
  float4 MaterialConstant_Z_272;
};

struct RenderStateConstant_Z {
  float RenderStateConstant_Z_000;
  int RenderStateConstant_Z_004;
  int RenderStateConstant_Z_008;
  int RenderStateConstant_Z_012;
};

Texture2D<float4> t0 : register(t0);
Texture2DArray<float4> t1 : register(t1);

cbuffer cb0 : register(b0) {
  GlobalCB_Z Global_000 : packoffset(c000.x);
};

cbuffer cb1 : register(b1) {
  RenderStateConstant_Z RenderState_000 : packoffset(c000.x);
};

cbuffer cb2 : register(b2) {
  MaterialConstant_Z Mtl_000 : packoffset(c000.x);
};

SamplerState s0 : register(s0);

float4 main(
  linear float4 COLOR : COLOR,
  linear float4 TEXCOORD : TEXCOORD,
  noperspective float4 SV_Position : SV_Position
) : SV_Target {
  float4 SV_Target;
  float4 _20 = t0.Sample(s0, float2(TEXCOORD.x, TEXCOORD.y));
  float _25 = _20.x * COLOR.x;
  float _26 = _20.y * COLOR.y;
  float _27 = _20.z * COLOR.z;
  float _28 = _20.w * COLOR.w;
  float _33 = _25 * Mtl_000.MaterialConstant_Z_000.x;
  float _34 = _26 * Mtl_000.MaterialConstant_Z_000.y;
  float _35 = _27 * Mtl_000.MaterialConstant_Z_000.z;
  float _40 = _33 + Mtl_000.MaterialConstant_Z_016.x;
  float _41 = _34 + Mtl_000.MaterialConstant_Z_016.y;
  float _42 = _35 + Mtl_000.MaterialConstant_Z_016.z;
  float _44 = _28 * Mtl_000.MaterialConstant_Z_028;
  bool _47 = !(_44 <= RenderState_000.RenderStateConstant_Z_000);
  float _110;
  float _111;
  float _112;
  if (!_47) {
    if (true) discard;
  }
  int _52 = asint((Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[1].x));
  int _53 = _52 & 458752;
  bool _54 = ((uint)_53 > (uint)262144);
  if (_54) {
    int _56 = _52 & 1;
    bool _57 = (_56 == 0);
    uint _58 = uint(SV_Position.x);
    uint _59 = uint(SV_Position.y);
    int _60 = _58 & 63;
    int _61 = _59 & 63;
    float4 _63 = t1.Load(int4(_60, _61, 0, 0));
    bool _65 = (_40 > 0.0f);
    bool _66 = (_41 > 0.0f);
    bool _67 = (_42 > 0.0f);
    float _68 = float((bool)_65);
    float _69 = float((bool)_66);
    float _70 = float((bool)_67);
    if (!_57) {
      float _72 = log2(_40);
      float _73 = log2(_41);
      float _74 = log2(_42);
      float _75 = floor(_72);
      float _76 = floor(_73);
      float _77 = floor(_74);
      float _78 = _75 + -6.0f;
      float _79 = _76 + -6.0f;
      float _80 = _77 + -5.0f;
      float _81 = exp2(_78);
      float _82 = exp2(_79);
      float _83 = exp2(_80);
      bool _84 = (_40 <= 0.0f);
      bool _85 = (_41 <= 0.0f);
      bool _86 = (_42 <= 0.0f);
      float _87 = select(_84, 0.0f, _81);
      float _88 = select(_85, 0.0f, _82);
      float _89 = select(_86, 0.0f, _83);
      float _90 = _87 * _63.x;
      float _91 = _87 - _90;
      float _92 = _91 * _68;
      float _93 = _63.x * _69;
      float _94 = _93 * _88;
      float _95 = _63.x * _70;
      float _96 = _95 * _89;
      float _97 = _92 + _40;
      float _98 = _94 + _41;
      float _99 = _96 + _42;
      _110 = _97;
      _111 = _98;
      _112 = _99;
    } else {
      float _101 = _63.x * 0.003921568859368563f;
      float _102 = 0.003921568859368563f - _101;
      float _103 = _102 * _68;
      float _104 = _101 * _69;
      float _105 = _101 * _70;
      float _106 = _103 + _40;
      float _107 = _104 + _41;
      float _108 = _105 + _42;
      _110 = _106;
      _111 = _107;
      _112 = _108;
    }
  } else {
    _110 = _40;
    _111 = _41;
    _112 = _42;
  }
  SV_Target.rgb = ResonanceScaleUIEncoded(float3(_110, _111, _112));
  SV_Target.w = _44;
  return SV_Target;
}
