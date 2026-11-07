// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
// Decompiled native F716B319. Only resource/function arguments are adapted.
#ifndef REMASTERED_NATIVE_CLOUD_ATLAS
#define REMASTERED_NATIVE_CLOUD_ATLAS
float4 GraphicsNativeCloudAtlas(Texture2D<float4> t0, SamplerState s8, float2 TEXCOORD) {
  float4 SV_Target = 0;
  float _5 = TEXCOORD.x * 2.0f;
  float _6 = TEXCOORD.y * 2.0f;
  float _7 = _5 + -1.0f;
  float _8 = _6 + -1.0f;
  float _9 = _7 - _8;
  float _10 = abs(_9);
  float _11 = _10 * 0.5f;
  float _12 = 1.0f - _11;
  float _13 = _8 + _7;
  float _14 = abs(_13);
  float _15 = _14 * 0.5f;
  float _16 = _12 - _15;
  float _17 = dot(float3(_7, _8, _16), float3(_7, _8, _16));
  float _18 = rsqrt(_17);
  float _19 = _18 * _7;
  float _20 = _18 * _8;
  float _21 = _16 * _18;
  float _22 = abs(_19);
  float _23 = abs(_20);
  bool _24 = !(_22 >= _23);
  bool _66;
  float _67;
  float _68;
  float _69;
  float _74;
  float _75;
  bool _85;
  int _86;
  float _87;
  float _88;
  float _89;
  float _91;
  float _92;
  bool _102;
  int _103;
  float _104;
  float _105;
  float _106;
  bool _112;
  int _113;
  float _114;
  float _115;
  float _116;
  if (!_24) {
    float _26 = abs(_21);
    bool _27 = (_22 >= _26);
    _66 = _27;
    _67 = _19;
    _68 = _20;
    _69 = _21;
  } else {
    _66 = false;
    _67 = 0.0f;
    _68 = 0.0f;
    _69 = 0.0f;
  }
  if (!_66) {
    float _71 = abs(_21);
    bool _72 = !(_23 >= _71);
    if (!_72) {
      bool _100 = (_23 >= _22);
      _102 = _100;
      _103 = 1;
      _104 = _20;
      _105 = _21;
      _106 = _19;
    } else {
      _102 = false;
      _103 = 0;
      _104 = 0.0f;
      _105 = 0.0f;
      _106 = 0.0f;
    }
    if (!_102) {
      bool _108 = !(_71 >= _22);
      if (!_108) {
        bool _110 = (_71 >= _23);
        _112 = _110;
        _113 = 2;
        _114 = _21;
        _115 = _19;
        _116 = _20;
      } else {
        _112 = false;
        _113 = 0;
        _114 = 0.0f;
        _115 = 0.0f;
        _116 = 0.0f;
      }
      int _117 = select(_112, _113, 0);
      float _118 = select(_112, _114, 0.0f);
      float _119 = select(_112, _115, 0.0f);
      float _120 = select(_112, _116, 0.0f);
      _85 = _112;
      _86 = _117;
      _87 = _118;
      _88 = _119;
      _89 = _120;
    } else {
      _85 = true;
      _86 = _103;
      _87 = _104;
      _88 = _105;
      _89 = _106;
    }
  } else {
    _85 = true;
    _86 = 0;
    _87 = _67;
    _88 = _68;
    _89 = _69;
  }
  while(true) {
    if (_85) {
      while(true) {
        float _29 = float((int)(_86));
        bool _30 = (_87 < 0.0f);
        float _31 = float((bool)_30);
        bool _32 = (_86 == 0);
        if (_32) {
          bool _34 = (_87 > 0.0f);
          int _35 = (int)(uint)(_34);
          int _36 = (int)(uint)(_30);
          int _37 = _35 - _36;
          float _38 = float((int)(_37));
          float _39 = -0.0f - _89;
          float _40 = _38 * _88;
          float _41 = _39 / _87;
          float _42 = _40 / _87;
          _74 = _41;
          _75 = _42;
        } else {
          bool _44 = (_86 == 1);
          if (_44) {
            bool _46 = (_87 > 0.0f);
            int _47 = (int)(uint)(_46);
            int _48 = (int)(uint)(_30);
            int _49 = _48 - _47;
            float _50 = float((int)(_49));
            float _51 = _50 * _89;
            float _52 = _51 / _87;
            float _53 = _88 / _87;
            _74 = _52;
            _75 = _53;
          } else {
            bool _55 = (_86 == 2);
            if (_55) {
              bool _57 = (_87 > 0.0f);
              int _58 = (int)(uint)(_57);
              int _59 = (int)(uint)(_30);
              int _60 = _58 - _59;
              float _61 = float((int)(_60));
              float _62 = _61 * _89;
              float _63 = _88 / _87;
              float _64 = _62 / _87;
              _74 = _63;
              _75 = _64;
            } else {
              _74 = 0.0f;
              _75 = 0.0f;
            }
          }
        }
        float _76 = _74 * 0.498046875f;
        float _77 = _75 * 0.498046875f;
        float _78 = _29 + 0.5f;
        float _79 = _78 + _76;
        float _80 = _31 + 0.5f;
        float _81 = _80 + _77;
        float _82 = _79 * 0.3333333432674408f;
        float _83 = _81 * 0.5f;
        _91 = _82;
        _92 = _83;
        break;
      }
    } else {
      _91 = 0.0f;
      _92 = 0.0f;
    }
    float4 _95 = t0.SampleLevel(s8, float2(_91, _92), 0.0f);
    SV_Target.x = _95.x;
    SV_Target.y = _95.y;
    SV_Target.z = _95.z;
    SV_Target.w = 1.0f;
    break;
  }
  return SV_Target;
}

#endif
