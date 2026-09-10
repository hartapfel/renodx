#include "../common.hlsli"

ByteAddressBuffer t1_space1 : register(t1, space1);

cbuffer cb14 : register(b14) {
  int RootSrtCbv_000 : packoffset(c000.x);
  int RootSrtCbv_004 : packoffset(c000.y);
};

SamplerState s12 : register(s12);

SamplerState s1 : register(s1);

float4 main(
  noperspective float4 SV_Position : SV_Position,
  linear float2 TEXCOORD : TEXCOORD
) : SV_Target {
  float4 SV_Target = 0;
  SV_Target.x = 0.0f;
  SV_Target.y = 0.0f;
  SV_Target.z = 0.0f;
  SV_Target.w = 0.0f;
  uint _11 = (uint)(RootSrtCbv_000) + 32u;
  uint _12 = (uint)(RootSrtCbv_000) + 64u;
  float4 _13 = asfloat(t1_space1.Load4(_12));
  uint _16 = (uint)(RootSrtCbv_000) + 96u;
  SV_Target.x = 0.0f;
  SV_Target.y = 0.0f;
  SV_Target.z = 0.0f;
  SV_Target.w = 0.0f;
  int4 _17 = asint(t1_space1.Load4(RootSrtCbv_000));
  Texture2D<float4> _20 = ResourceDescriptorHeap[(uint)(_17.x)];
  float4 _22 = _20.Sample(s12, float2(TEXCOORD.x, TEXCOORD.y));
  if (GhostIsSDRReference()) {
    // Native SDR composes scene and HUD before 0x571EE768 applies its
    // display transfer. Interpret those codes with gamma 2.2 exactly once,
    // then place the bounded BT.709 image in a fixed 203-nit HDR10 container.
    return float4(renodx::color::pq::EncodeSafe(
                      renodx::color::bt2020::from::BT709(
                          renodx::color::gamma::DecodeSafe(
                              saturate(GhostSDRDisplayCode(
                                  renodx::color::srgb::DecodeSafe(saturate(_22.rgb)))),
                              2.2f)),
                      GHOST_SDR_REFERENCE_WHITE_NITS),
                  1.f);
  }
  uint _26 = (uint)(RootSrtCbv_000) + 112u;
  float4 _27 = asfloat(t1_space1.Load4(_26));
  float _29 = _27.x * _22.x;
  float _30 = _27.x * _22.y;
  float _31 = _27.x * _22.z;
  uint _32 = (uint)(RootSrtCbv_000) + 108u;
  float4 _33 = asfloat(t1_space1.Load4(_32));
  float _35 = _29 + _33.x;
  float _36 = _30 + _33.x;
  float _37 = _31 + _33.x;
  float _38 = _35 * _22.x;
  float _39 = _36 * _22.y;
  float _40 = _37 * _22.z;
  uint _41 = (uint)(RootSrtCbv_000) + 104u;
  float4 _42 = asfloat(t1_space1.Load4(_41));
  float _44 = _38 + _42.x;
  float _45 = _39 + _42.x;
  float _46 = _40 + _42.x;
  float _47 = _44 * _22.x;
  float _48 = _45 * _22.y;
  float _49 = _46 * _22.z;
  uint _50 = (uint)(RootSrtCbv_000) + 100u;
  float4 _51 = asfloat(t1_space1.Load4(_50));
  float _53 = _47 + _51.x;
  float _54 = _48 + _51.x;
  float _55 = _49 + _51.x;
  float _56 = _53 * _22.x;
  float _57 = _54 * _22.y;
  float _58 = _55 * _22.z;
  float4 _59 = asfloat(t1_space1.Load4(_16));
  float _61 = _56 + _59.x;
  float _62 = _57 + _59.x;
  float _63 = _58 + _59.x;
  float _64 = _61 * _22.x;
  float _65 = _62 * _22.y;
  float _66 = _63 * _22.z;
  uint _67 = (uint)(RootSrtCbv_000) + 124u;
  float4 _68 = asfloat(t1_space1.Load4(_67));
  float _70 = _68.x * _22.x;
  float _71 = _68.x * _22.y;
  float _72 = _68.x * _22.z;
  uint _73 = (uint)(RootSrtCbv_000) + 120u;
  float4 _74 = asfloat(t1_space1.Load4(_73));
  float _76 = _70 + _74.x;
  float _77 = _71 + _74.x;
  float _78 = _72 + _74.x;
  float _79 = _76 * _22.x;
  float _80 = _77 * _22.y;
  float _81 = _78 * _22.z;
  uint _82 = (uint)(RootSrtCbv_000) + 116u;
  float4 _83 = asfloat(t1_space1.Load4(_82));
  float _85 = _79 + _83.x;
  float _86 = _80 + _83.x;
  float _87 = _81 + _83.x;
  float _88 = _85 * _22.x;
  float _89 = _86 * _22.y;
  float _90 = _87 * _22.z;
  float _91 = _88 + 1.0f;
  float _92 = _89 + 1.0f;
  float _93 = _90 + 1.0f;
  float _94 = _64 / _91;
  float _95 = _65 / _92;
  float _96 = _66 / _93;
  float _97 = _94 * 0.627403736114502f;
  float _98 = mad(_95, 0.329281747341156f, _97);
  float _99 = mad(_96, 0.043313510715961456f, _98);
  float _100 = _94 * 0.06909702718257904f;
  float _101 = mad(_95, 0.9195404052734375f, _100);
  float _102 = mad(_96, 0.011362077668309212f, _101);
  float _103 = _94 * 0.016391443088650703f;
  float _104 = mad(_95, 0.08801350742578506f, _103);
  float _105 = mad(_96, 0.8955950140953064f, _104);
  float _106 = sqrt(_99);
  float _107 = sqrt(_102);
  float _108 = sqrt(_105);
  float _109 = _106 * 0.16258220374584198f;
  float _110 = _107 * 0.16258220374584198f;
  float _111 = _108 * 0.16258220374584198f;
  float _112 = _109 + 8.069647789001465f;
  float _113 = _110 + 8.069647789001465f;
  float _114 = _111 + 8.069647789001465f;
  float _115 = _112 * _106;
  float _116 = _113 * _107;
  float _117 = _114 * _108;
  float _118 = _115 + 3.520920515060425f;
  float _119 = _116 + 3.520920515060425f;
  float _120 = _117 + 3.520920515060425f;
  float _121 = _118 * _106;
  float _122 = _119 * _107;
  float _123 = _120 * _108;
  float _124 = _121 + 0.00048778101336210966f;
  float _125 = _122 + 0.00048778101336210966f;
  float _126 = _123 + 0.00048778101336210966f;
  float _127 = _106 * 7.964550971984863f;
  float _128 = _107 * 7.964550971984863f;
  float _129 = _108 * 7.964550971984863f;
  float _130 = _127 + 10.530847549438477f;
  float _131 = _128 + 10.530847549438477f;
  float _132 = _129 + 10.530847549438477f;
  float _133 = _130 * _106;
  float _134 = _131 * _107;
  float _135 = _132 * _108;
  float _136 = _133 + 1.0f;
  float _137 = _134 + 1.0f;
  float _138 = _135 + 1.0f;
  float _139 = _124 / _136;
  float _140 = _125 / _137;
  float _141 = _126 / _138;
  int4 _142 = asint(t1_space1.Load4(_11));
  Texture2D<float> _145 = ResourceDescriptorHeap[(uint)(_142.x)];
  float _146 = _13.x * TEXCOORD.x;
  float _147 = _13.y * TEXCOORD.y;
  float _148 = _146 + 0.5f;
  float _149 = _147 + 0.5f;
  float _151 = _145.SampleLevel(s1, float2(_148, _149), 0.0f);
  float _153 = _151.x * 0.0009775171056389809f;
  float _154 = _153 + -0.0004887585528194904f;
  if (GhostIsPsychoV()) {
    // Clamp the absolute-nit PQ BT.2020 intermediate and write HDR10 PQ.
    const float ghost_peak_pq = renodx::color::pq::EncodeSafe(
        max(RENODX_PEAK_WHITE_NITS, 1.f).xxx,
        1.f).x;
    SV_Target.rgb = clamp(
        GhostEncodeHDR10(_22.rgb) + _154,
        0.f.xxx,
        ghost_peak_pq.xxx);
    SV_Target.w = 1.0f;
    return SV_Target;
  }
  float _155 = _154 + _139;
  float _156 = _154 + _140;
  float _157 = _154 + _141;
  SV_Target.x = _155;
  SV_Target.y = _156;
  SV_Target.z = _157;
  SV_Target.w = 1.0f;
  return SV_Target;
}
