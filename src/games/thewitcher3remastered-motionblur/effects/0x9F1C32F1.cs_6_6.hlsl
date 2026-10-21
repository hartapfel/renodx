#include "motion_depth.hlsli"
RWStructuredBuffer<float4> motion_scratch : register(u0, space57);
Texture2D<float4> t0 : register(t0);

Texture2D<float4> t1 : register(t1);

RWTexture2D<float4> u0 : register(u0);

cbuffer cb10 : register(b10) {
  float4 ConvertMotionVectorsData_000 : packoffset(c000.x);
  row_major float4x4 ConvertMotionVectorsData_016 : packoffset(c001.x);
};

[numthreads(8, 8, 1)]
void main(
  uint3 SV_DispatchThreadID : SV_DispatchThreadID,
  uint3 SV_GroupID : SV_GroupID,
  uint3 SV_GroupThreadID : SV_GroupThreadID,
  uint SV_GroupIndex : SV_GroupIndex
) {
  // Copy only five float4s on the GPU, using the already-bound native b10.
  // Keep native motion XY unchanged for every other consumer of this texture.
  if (all(SV_DispatchThreadID == 0u)) {
    motion_scratch[1] = ConvertMotionVectorsData_000;
    motion_scratch[2] = ConvertMotionVectorsData_016[0];
    motion_scratch[3] = ConvertMotionVectorsData_016[1];
    motion_scratch[4] = ConvertMotionVectorsData_016[2];
    motion_scratch[5] = ConvertMotionVectorsData_016[3];
  }
  float _8 = float((uint)SV_DispatchThreadID.x);
  float _9 = float((uint)SV_DispatchThreadID.y);
  float _10 = _8 + 0.5f;
  float _11 = _9 + 0.5f;
  uint _15 = uint(ConvertMotionVectorsData_000.x);
  uint _16 = uint(ConvertMotionVectorsData_000.y);
  bool _17 = ((uint)(int)(SV_DispatchThreadID.x) >= (uint)_15);
  bool _18 = ((uint)(int)(SV_DispatchThreadID.y) >= (uint)_16);
  bool _19 = _17 || _18;
  float _78;
  float _79;
  if (!_19) {
    float4 _22 = t1.Load(int3((int)(SV_DispatchThreadID.x), (int)(SV_DispatchThreadID.y), 0));
    bool _25 = (_22.x >= 2.0f);
    bool _26 = (_22.y >= 2.0f);
    bool _27 = _25 || _26;
    [branch]
    if (_27) {
      float _32 = ConvertMotionVectorsData_000.z * _10;
      float _33 = ConvertMotionVectorsData_000.w * _11;
      float4 _35 = t0.Load(int3((int)(SV_DispatchThreadID.x), (int)(SV_DispatchThreadID.y), 0));
      float _37 = _32 * 2.0f;
      float _38 = _37 + -1.0f;
      float _39 = _33 * 2.0f;
      float _40 = 1.0f - _39;
      float _57 = (ConvertMotionVectorsData_016[0].x) * _38;
      float _58 = mad((ConvertMotionVectorsData_016[1].x), _40, _57);
      float _59 = mad((ConvertMotionVectorsData_016[2].x), _35.x, _58);
      float _60 = _59 + (ConvertMotionVectorsData_016[3].x);
      float _61 = (ConvertMotionVectorsData_016[0].y) * _38;
      float _62 = mad((ConvertMotionVectorsData_016[1].y), _40, _61);
      float _63 = mad((ConvertMotionVectorsData_016[2].y), _35.x, _62);
      float _64 = _63 + (ConvertMotionVectorsData_016[3].y);
      float _65 = (ConvertMotionVectorsData_016[0].w) * _38;
      float _66 = mad((ConvertMotionVectorsData_016[1].w), _40, _65);
      float _67 = mad((ConvertMotionVectorsData_016[2].w), _35.x, _66);
      float _68 = _67 + (ConvertMotionVectorsData_016[3].w);
      float _69 = _60 * 0.5f;
      float _70 = _64 * -0.5f;
      float _71 = _69 / _68;
      float _72 = _70 / _68;
      float _73 = _32 + -0.5f;
      float _74 = _73 - _71;
      float _75 = _33 + -0.5f;
      float _76 = _75 - _72;
      _78 = _74;
      _79 = _76;
    } else {
      _78 = _22.x;
      _79 = _22.y;
    }
    float _80 = -0.0f - _78;
    float _81 = -0.0f - _79;
    // XY are the unmodified native conversion. Native blur consumers read XY
    // only. Carry raw depth in the unused channels, avoiding a separate copy
    // pass and CPU tracking of which depth texture belongs to this motion view.
    float depth = t0.Load(int3(SV_DispatchThreadID.xy, 0)).x;
    u0[SV_DispatchThreadID.xy] = float4(_80, _81, PackMotionDepth(depth));
  }
}
