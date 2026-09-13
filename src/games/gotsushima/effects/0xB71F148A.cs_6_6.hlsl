#include "../shared.h"

ByteAddressBuffer t1_space1 : register(t1, space1);

cbuffer cb14 : register(b14) {
  int RootSrtCbv_000 : packoffset(c000.x);
  int RootSrtCbv_004 : packoffset(c000.y);
};

static const float _global_0[8] = { 1.0f, 1.0f, 3.0f, 1.0f, 1.0f, 3.0f, 3.0f, 3.0f };

[numthreads(8, 8, 1)]
void main(
  uint3 SV_DispatchThreadID : SV_DispatchThreadID,
  uint3 SV_GroupID : SV_GroupID,
  uint3 SV_GroupThreadID : SV_GroupThreadID,
  uint SV_GroupIndex : SV_GroupIndex
) {
  uint _10 = (uint)(RootSrtCbv_000) + 32u;
  uint _11 = (uint)(RootSrtCbv_000) + 64u;
  uint _12 = (uint)(RootSrtCbv_000) + 96u;
  uint _13 = (uint)(RootSrtCbv_000) + 112u;
  uint _14 = (uint)(RootSrtCbv_000) + 128u;
  float4 _15 = asfloat(t1_space1.Load4(_14));
  uint _18 = (uint)(RootSrtCbv_000) + 136u;
  float4 _19 = asfloat(t1_space1.Load4(_18));
  uint _22 = (uint)(RootSrtCbv_000) + 156u;
  float4 _23 = asfloat(t1_space1.Load4(_22));
  uint _24 = (uint)(RootSrtCbv_000) + 164u;
  float4 _25 = asfloat(t1_space1.Load4(_24));
  uint _28 = (uint)(RootSrtCbv_000) + 172u;
  int _29 = (int)(SV_GroupIndex) & 3;
  int _30 = (int)(SV_DispatchThreadID.x) & -8;
  int _31 = (uint)(SV_DispatchThreadID.x) >> 1;
  int _32 = _31 & 2;
  int _33 = _32 | _30;
  uint _34 = SV_DispatchThreadID.y << 1u;
  int _35 = _34 & 4;
  int _36 = _33 | _35;
  int _37 = (int)(SV_DispatchThreadID.y) & -4;
  int _38 = _34 & 2;
  int _39 = _38 | _37;
  int _40 = (uint)(_36) >> 1;
  int _41 = (uint)(_39) >> 1;
  float _42 = float((uint)_40);
  float _43 = float((uint)_41);
  float _44 = _19.x * _42;
  float _45 = _19.y * _43;
  uint _46 = _29 * 2;
  uint _47 = 0u + _46;
  float _49 = _global_0[_47];
  uint _50 = _29 * 2;
  uint _51 = 1u + _50;
  float _53 = _global_0[_51];
  float _54 = _49 * _15.x;
  float _55 = _53 * _15.y;
  float _56 = _54 + _44;
  float _57 = _55 + _45;
  bool _58 = (_56 > _25.x);
  bool _59 = (_57 > _25.y);
  bool _60 = _58 || _59;
  float _154;
  float _155;
  float _156;
  if (!_60) {
    bool _64 = (_56 < _23.x);
    bool _65 = (_57 < _23.y);
    bool _66 = _64 || _65;
    if (!_66) {
      int4 _68 = asint(t1_space1.Load4(_10));
      Texture2D<float> _71 = ResourceDescriptorHeap[(uint)(_68.x)];
      int4 _72 = asint(t1_space1.Load4(_13));
      SamplerComparisonState _75 = SamplerDescriptorHeap[(uint)(_72.x)];
      float _76 = _71.SampleCmpLevelZero(_75, float2(_56, _57), 0.0f);
      int4 _78 = asint(t1_space1.Load4(RootSrtCbv_000));
      Texture2D<float3> _81 = ResourceDescriptorHeap[(uint)(_78.x)];
      int4 _82 = asint(t1_space1.Load4(_12));
      SamplerState _85 = SamplerDescriptorHeap[(uint)(_82.x)];
      float3 _86 = _81.SampleLevel(_85, float2(_56, _57), 0.0f);
      float _90 = _76.x * 4.0f;
      int _91 = int(_90);
      uint _92 = _91 * 20;
      uint _93 = _92 + _28;
      float4 _94 = asfloat(t1_space1.Load4(_93));
      uint _96 = (uint)(RootSrtCbv_000) + 176u;
      uint _97 = _96 + _92;
      float4 _98 = asfloat(t1_space1.Load4(_97));
      uint _100 = (uint)(RootSrtCbv_000) + 180u;
      uint _101 = _100 + _92;
      float4 _102 = asfloat(t1_space1.Load4(_101));
      uint _104 = (uint)(RootSrtCbv_000) + 184u;
      uint _105 = _104 + _92;
      float4 _106 = asfloat(t1_space1.Load4(_105));
      uint _108 = (uint)(RootSrtCbv_000) + 188u;
      uint _109 = _108 + _92;
      float4 _110 = asfloat(t1_space1.Load4(_109));
      float _112 = _86.x - _98.x;
      float _113 = _86.y - _98.x;
      float _114 = _86.z - _98.x;
      float _115 = max(0.0f, _112);
      float _116 = max(0.0f, _113);
      float _117 = max(0.0f, _114);
      float _118 = _115 * _115;
      float _119 = _118 * _94.x;
      float _120 = _116 * _116;
      float _121 = _120 * _94.x;
      float _122 = _117 * _117;
      float _123 = _122 * _94.x;
      float _124 = _115 + _102.x;
      float _125 = _116 + _102.x;
      float _126 = _117 + _102.x;
      float _127 = max(_124, 0.0010000000474974513f);
      float _128 = max(_125, 0.0010000000474974513f);
      float _129 = max(_126, 0.0010000000474974513f);
      float _130 = _119 / _127;
      float _131 = _121 / _128;
      float _132 = _123 / _129;
      float _133 = dot(float3(_130, _131, _132), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
      float _134 = _133 * _110.x;
      float _135 = _134 + 0.5f;
      float _136 = saturate(_135);
      float _137 = _136 * 2.0f;
      float _138 = 3.0f - _137;
      float _139 = _136 * _136;
      float _140 = _139 * 2.0f;
      float _141 = _140 * _138;
      float _142 = _141 + -1.0f;
      float _143 = saturate(_142);
      float _144 = _143 * _106.x;
      float _145 = max(_133, 0.0010000000474974513f);
      float _146 = _144 / _145;
      float _147 = _146 * _130;
      float _148 = _146 * _131;
      float _149 = _146 * _132;
      float _150 = max(_147, 0.0f);
      float _151 = max(_148, 0.0f);
      float _152 = max(_149, 0.0f);
      _154 = _150;
      _155 = _151;
      _156 = _152;
    } else {
      _154 = 0.0f;
      _155 = 0.0f;
      _156 = 0.0f;
    }
  } else {
    _154 = 0.0f;
    _155 = 0.0f;
    _156 = 0.0f;
  }
  GroupMemoryBarrier();
  int _157 = WaveGetLaneIndex();
  int _158 = _157 & 31;
  int _159 = _158 ^ 2;
  float _160 = WaveReadLaneAt(_154,_159);
  float _161 = _160 + _154;
  int _162 = _158 ^ 1;
  float _163 = WaveReadLaneAt(_161,_162);
  float _164 = WaveReadLaneAt(_155,_159);
  float _165 = _164 + _155;
  float _166 = WaveReadLaneAt(_165,_162);
  float _167 = WaveReadLaneAt(_156,_159);
  float _168 = _167 + _156;
  float _169 = WaveReadLaneAt(_168,_162);
  bool _170 = (_29 == 0);
  if (_170) {
    float _172 = _169 + _168;
    float _173 = _166 + _165;
    float _174 = _163 + _161;
    float _175 = _173 * 0.125f;
    float _176 = _172 + _174;
    float _177 = _176 * 0.0625f;
    float _178 = _177 + _175;
    float _179 = _174 - _172;
    float _180 = _179 * 0.125f;
    float _181 = _174 * 0.0625f;
    float _182 = _175 - _181;
    float _183 = _172 * 0.0625f;
    float _184 = _182 - _183;
    int4 _185 = asint(t1_space1.Load4(_11));
    RWTexture2D<float3> _188 = ResourceDescriptorHeap[(uint)(_185.x)];
    // Scale the extracted bloom after its native limiter. All three packed
    // Y/Cg/Co components receive the same gain before the linear blur pyramid.
    // Lens flares are generated separately later in the frame.
    float3 ghost_bloom = float3(_178, _184, _180);
    if (RENODX_TONE_MAP_TYPE == 1.f && RENODX_PEAK_WHITE_NITS > 0.f) {
      ghost_bloom *= CUSTOM_BLOOM_INTENSITY;
    }
    _188[int2(_40, _41)] = ghost_bloom;
  }
}
