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

struct ShaderNode_Z {
  float4 ShaderNode_Z_000;
  int ShaderNode_Z_016;
  float ShaderNode_Z_020;
  float ShaderNode_Z_024;
  float ShaderNode_Z_028;
  float4 ShaderNode_Z_032[2];
  float4 ShaderNode_Z_064[2];
};

struct NodeConstant_Z {
  ShaderNode_Z NodeConstant_Z_000[16];
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
  NodeConstant_Z Node_000 : packoffset(c000.x);
};

cbuffer cb3 : register(b3) {
  MaterialConstant_Z Mtl_000 : packoffset(c000.x);
};

SamplerState s0 : register(s0);

float4 main(
  linear float4 PREVIOUS_POSITION : PREVIOUS_POSITION,
  linear float4 TEXCOORD : TEXCOORD,
  noperspective float4 SV_Position : SV_Position,
  linear float3 COLOR_RGB : COLOR_RGB,
  linear float COLOR_ALPHA : COLOR_ALPHA,
  linear float3 TEXSPACE_NORMAL : TEXSPACE_NORMAL,
  linear float3 TEXSPACE_POS : TEXSPACE_POS,
  nointerpolation uint SV_IsFrontFace : SV_IsFrontFace
) : SV_Target {
  float4 SV_Target;
  float4 _27 = t0.Sample(s0, float2(TEXCOORD.x, TEXCOORD.y));
  float _38 = _27.w * COLOR_ALPHA;
  float _39 = _38 * Mtl_000.MaterialConstant_Z_028;
  float _40 = (Node_000.NodeConstant_Z_000[0].ShaderNode_Z_000.x) * COLOR_RGB.x;
  float _41 = _40 * _27.x;
  float _42 = _41 * Mtl_000.MaterialConstant_Z_000.x;
  float _43 = (Node_000.NodeConstant_Z_000[0].ShaderNode_Z_000.y) * COLOR_RGB.y;
  float _44 = _43 * _27.y;
  float _45 = _44 * Mtl_000.MaterialConstant_Z_000.y;
  float _46 = (Node_000.NodeConstant_Z_000[0].ShaderNode_Z_000.z) * COLOR_RGB.z;
  float _47 = _46 * _27.z;
  float _48 = _47 * Mtl_000.MaterialConstant_Z_000.z;
  int _51 = (Node_000.NodeConstant_Z_000[0].ShaderNode_Z_016) & 262144;
  bool _52 = (_51 == 0);
  float _53 = select(_52, _42, (Node_000.NodeConstant_Z_000[0].ShaderNode_Z_000.x));
  float _54 = select(_52, _45, (Node_000.NodeConstant_Z_000[0].ShaderNode_Z_000.y));
  float _55 = select(_52, _48, (Node_000.NodeConstant_Z_000[0].ShaderNode_Z_000.z));
  bool _58 = !(_39 <= RenderState_000.RenderStateConstant_Z_000);
  float _140;
  float _141;
  float _142;
  if (!_58) {
    if (true) discard;
  }
  float _63 = _39 * (Node_000.NodeConstant_Z_000[0].ShaderNode_Z_000.w);
  float _64 = saturate(_63);
  int _65 = int(SV_Position.x);
  int _66 = int(SV_Position.y);
  float _67 = log2(_53);
  float _68 = log2(_54);
  float _69 = log2(_55);
  float _70 = _67 * 0.4166666567325592f;
  float _71 = _68 * 0.4166666567325592f;
  float _72 = _69 * 0.4166666567325592f;
  float _73 = exp2(_70);
  float _74 = exp2(_71);
  float _75 = exp2(_72);
  float _76 = _73 * 1.0549999475479126f;
  float _77 = _74 * 1.0549999475479126f;
  float _78 = _75 * 1.0549999475479126f;
  float _79 = _76 + -0.054999999701976776f;
  float _80 = _77 + -0.054999999701976776f;
  float _81 = _78 + -0.054999999701976776f;
  float _82 = _53 * 12.920000076293945f;
  float _83 = _54 * 12.920000076293945f;
  float _84 = _55 * 12.920000076293945f;
  bool _85 = (_53 <= 0.0031308000907301903f);
  bool _86 = (_54 <= 0.0031308000907301903f);
  bool _87 = (_55 <= 0.0031308000907301903f);
  float _88 = select(_85, _82, _79);
  float _89 = select(_86, _83, _80);
  float _90 = select(_87, _84, _81);
  int _92 = asint((Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[1].x));
  int _93 = _92 & 1;
  bool _94 = (_93 == 0);
  float _95 = float((int)(_65));
  float _96 = float((int)(_66));
  uint _97 = uint(_95);
  uint _98 = uint(_96);
  int _99 = _97 & 63;
  int _100 = _98 & 63;
  float4 _101 = t1.Load(int4(_99, _100, 0, 0));
  bool _103 = (_88 > 0.0f);
  bool _104 = (_89 > 0.0f);
  bool _105 = (_90 > 0.0f);
  float _106 = float((bool)_103);
  float _107 = float((bool)_104);
  float _108 = float((bool)_105);
  if (!_94) {
    float _110 = log2(_88);
    float _111 = log2(_89);
    float _112 = log2(_90);
    float _113 = floor(_110);
    float _114 = floor(_111);
    float _115 = floor(_112);
    float _116 = _113 + -6.0f;
    float _117 = _114 + -6.0f;
    float _118 = _115 + -5.0f;
    float _119 = exp2(_116);
    float _120 = exp2(_117);
    float _121 = exp2(_118);
    bool _122 = (_88 <= 0.0f);
    bool _123 = (_89 <= 0.0f);
    bool _124 = (_90 <= 0.0f);
    float _125 = select(_122, 0.0f, _119);
    float _126 = select(_123, 0.0f, _120);
    float _127 = select(_124, 0.0f, _121);
    float _128 = _125 * _101.x;
    float _129 = _125 - _128;
    float _130 = _107 * _101.x;
    float _131 = _130 * _126;
    float _132 = _108 * _101.x;
    float _133 = _132 * _127;
    _140 = _129;
    _141 = _131;
    _142 = _133;
  } else {
    float _135 = _101.x * 0.003921568859368563f;
    float _136 = 0.003921568859368563f - _135;
    float _137 = _107 * _135;
    float _138 = _108 * _135;
    _140 = _136;
    _141 = _137;
    _142 = _138;
  }
  float _143 = _140 * _106;
  float _144 = _143 + _88;
  float _145 = _141 + _89;
  float _146 = _142 + _90;
  float _149 = dot(float3(_144, _145, _146), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  float _150 = _149 - _144;
  float _151 = _149 - _145;
  float _152 = _149 - _146;
  float _153 = _150 * (Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[84].w);
  float _154 = _151 * (Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[84].w);
  float _155 = _152 * (Global_000.GlobalCB_Z_000.GlobalCB_Z__GlobalConstant_Z_000[84].w);
  float _156 = _153 + _144;
  float _157 = _154 + _145;
  float _158 = _155 + _146;
  SV_Target.rgb = ResonanceScaleUIEncoded(float3(_156, _157, _158));
  SV_Target.w = _64;
  return SV_Target;
}
