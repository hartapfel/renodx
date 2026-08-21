Texture2DArray<float4> sBlueNoiseR8 : register(t1);

Texture2D<float4> s0 : register(t0);

float4 main(
  linear float4 TEXCOORD : TEXCOORD,
  noperspective float4 SV_Position : SV_Position,
  nointerpolation uint2 INSTANCE_INDEXES : INSTANCE_INDEXES
) : SV_Target {
  float4 SV_Target;
  int _5 = int(SV_Position.x);
  int _6 = int(SV_Position.y);
  float4 _7 = s0.Load(int3(_5, _6, 0));
  float _12 = log2(_7.x);
  float _13 = log2(_7.y);
  float _14 = log2(_7.z);
  float _15 = floor(_12);
  float _16 = floor(_13);
  float _17 = floor(_14);
  float _18 = _15 + -6.0f;
  float _19 = _16 + -6.0f;
  float _20 = _17 + -5.0f;
  float _21 = exp2(_18);
  float _22 = exp2(_19);
  float _23 = exp2(_20);
  uint _24 = uint(SV_Position.x);
  uint _25 = uint(SV_Position.y);
  int _26 = _24 & 63;
  int _27 = _25 & 63;
  float4 _28 = sBlueNoiseR8.Load(int4(_26, _27, 0, 0));
  float _30 = _28.x + -0.5f;
  bool _31 = (_7.x > 0.0f);
  bool _32 = (_7.y > 0.0f);
  bool _33 = (_7.z > 0.0f);
  float _34 = float((bool)_31);
  float _35 = float((bool)_32);
  float _36 = float((bool)_33);
  float _37 = _21 * _34;
  float _38 = _37 * _30;
  float _39 = _22 * _35;
  float _40 = _39 * _30;
  float _41 = _23 * _36;
  float _42 = _41 * _30;
  float _43 = _38 + _7.x;
  float _44 = _40 + _7.y;
  float _45 = _42 + _7.z;
  SV_Target.x = _43;
  SV_Target.y = _44;
  SV_Target.z = _45;
  SV_Target.w = _7.w;
  return SV_Target;
}
