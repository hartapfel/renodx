#define FOG_RECEIVER_FRAME
cbuffer HartapfelReceiverFrame : register(b12) { float4 receiver_frame[341]; }
#include "fog/receivers.hlsli"
struct ShaderCommonEnvProbeParams {
  float ShaderCommonEnvProbeParams_000;
  float3 ShaderCommonEnvProbeParams_004;
  float3 ShaderCommonEnvProbeParams_016;
  row_major float4x4 ShaderCommonEnvProbeParams_028;
  float4 ShaderCommonEnvProbeParams_092;
  row_major float4x4 ShaderCommonEnvProbeParams_108;
  int ShaderCommonEnvProbeParams_172;
};

struct ShaderCullingEnvProbeParams {
  row_major float4x3 ShaderCullingEnvProbeParams_000;
  float3 ShaderCullingEnvProbeParams_048;
  int ShaderCullingEnvProbeParams_060;
};

struct ShaderWorldTear {
  float4 ShaderWorldTear_000;
  float4 ShaderWorldTear_016;
  float ShaderWorldTear_032;
  float ShaderWorldTear_036;
  float ShaderWorldTear_040;
  float ShaderWorldTear_044;
};

struct ShaderWorldTearArray {
  int ShaderWorldTearArray_000;
  float ShaderWorldTearArray_004;
  float ShaderWorldTearArray_008;
  float ShaderWorldTearArray_012;
  ShaderWorldTear ShaderWorldTearArray_016[10];
};

struct ShaderWorldTearConstants {
  int4 ShaderWorldTearConstants_000[16];
};


Texture2D<float4> t0 : register(t0);

Texture2D<float4> t1 : register(t1);

Texture2D<float4> t2 : register(t2);

Texture2D<uint> t3 : register(t3);

cbuffer cb3 : register(b3) {
  float4 CustomPixelConsts_000 : packoffset(c000.x);
  float4 CustomPixelConsts_016 : packoffset(c001.x);
  float4 CustomPixelConsts_032 : packoffset(c002.x);
  float4 CustomPixelConsts_048 : packoffset(c003.x);
  float4 CustomPixelConsts_064 : packoffset(c004.x);
  float4 CustomPixelConsts_080 : packoffset(c005.x);
  float4 CustomPixelConsts_096 : packoffset(c006.x);
  float4 CustomPixelConsts_112 : packoffset(c007.x);
  float4 CustomPixelConsts_128 : packoffset(c008.x);
  float4 CustomPixelConsts_144 : packoffset(c009.x);
  float4 CustomPixelConsts_160 : packoffset(c010.x);
  float4 CustomPixelConsts_176 : packoffset(c011.x);
  float4 CustomPixelConsts_192 : packoffset(c012.x);
  float4 CustomPixelConsts_208 : packoffset(c013.x);
  float4 CustomPixelConsts_224 : packoffset(c014.x);
  float4 CustomPixelConsts_240 : packoffset(c015.x);
  float4 CustomPixelConsts_256 : packoffset(c016.x);
  float4 CustomPixelConsts_272 : packoffset(c017.x);
  float4 CustomPixelConsts_288 : packoffset(c018.x);
  float4 CustomPixelConsts_304 : packoffset(c019.x);
  float4 CustomPixelConsts_320 : packoffset(c020.x);
  row_major float4x4 CustomPixelConsts_336 : packoffset(c021.x);
};

#define cb12_000x receiver_frame[0].x
#define cb12_000y receiver_frame[0].y
#define cb12_000z receiver_frame[0].z
#define cb12_022x receiver_frame[22].x
#define cb12_022y receiver_frame[22].y
#define cb12_022z receiver_frame[22].z
#define cb12_038x receiver_frame[38].x
#define cb12_038y receiver_frame[38].y
#define cb12_038z receiver_frame[38].z
#define cb12_039x receiver_frame[39].x
#define cb12_039y receiver_frame[39].y
#define cb12_039z receiver_frame[39].z
#define cb12_040x receiver_frame[40].x
#define cb12_040y receiver_frame[40].y
#define cb12_040z receiver_frame[40].z
#define cb12_041x receiver_frame[41].x
#define cb12_041y receiver_frame[41].y
#define cb12_041z receiver_frame[41].z
#define cb12_042x receiver_frame[42].x
#define cb12_042y receiver_frame[42].y
#define cb12_042z receiver_frame[42].z
#define cb12_042w receiver_frame[42].w
#define cb12_043x receiver_frame[43].x
#define cb12_043y receiver_frame[43].y
#define cb12_043z receiver_frame[43].z
#define cb12_045x receiver_frame[45].x
#define cb12_045y receiver_frame[45].y
#define cb12_045z receiver_frame[45].z
#define cb12_046x receiver_frame[46].x
#define cb12_046y receiver_frame[46].y
#define cb12_046z receiver_frame[46].z
#define cb12_047x receiver_frame[47].x
#define cb12_047y receiver_frame[47].y
#define cb12_047z receiver_frame[47].z
#define cb12_048x receiver_frame[48].x
#define cb12_048y receiver_frame[48].y
#define cb12_048z receiver_frame[48].z
#define cb12_189x receiver_frame[189].x
#define cb12_189y receiver_frame[189].y
#define cb12_189z receiver_frame[189].z
#define cb12_189w receiver_frame[189].w
#define cb12_190x receiver_frame[190].x
#define cb12_190y receiver_frame[190].y
#define cb12_190z receiver_frame[190].z
#define cb12_190w receiver_frame[190].w
#define cb12_191x receiver_frame[191].x
#define cb12_191y receiver_frame[191].y
#define cb12_191z receiver_frame[191].z
#define cb12_191w receiver_frame[191].w
#define cb12_192x receiver_frame[192].x
#define cb12_192y receiver_frame[192].y
#define cb12_192z receiver_frame[192].z
#define cb12_192w receiver_frame[192].w
#define cb12_193x receiver_frame[193].x
#define cb12_211x receiver_frame[211].x
#define cb12_211y receiver_frame[211].y
#define cb12_211z receiver_frame[211].z
#define cb12_211w receiver_frame[211].w
#define cb12_212x receiver_frame[212].x
#define cb12_212y receiver_frame[212].y
#define cb12_212z receiver_frame[212].z
#define cb12_212w receiver_frame[212].w
#define cb12_213x receiver_frame[213].x
#define cb12_213y receiver_frame[213].y
#define cb12_213z receiver_frame[213].z
#define cb12_213w receiver_frame[213].w
#define cb12_214x receiver_frame[214].x
#define cb12_214y receiver_frame[214].y
#define cb12_214z receiver_frame[214].z
#define cb12_214w receiver_frame[214].w
#define cb12_287z asint(receiver_frame[287].z)
#define cb12_padding asuint(receiver_frame[340].w)

float4 main(
  noperspective float4 SV_Position : SV_Position
) : SV_Target {
  float4 SV_Target = 0;
  uint _11 = uint(SV_Position.x);
  uint _12 = uint(SV_Position.y);
  float4 _14 = t0.Load(int3(_11, _12, 0));
  float _22 = float((uint)_11);
  float _23 = float((uint)_12);
  float _59 = mad(cb12_213w, _14.x, mad(cb12_212w, _23, (cb12_211w * _22))) + cb12_214w;
  float _79;
  float _94;
  bool _167;
  float _175;
  float _189;
  float _190;
  float _191;
  float _216;
  float _217;
  float _218;
  float _373;
  float _374;
  float _456;
  float _457;
  float _458;
  float _459;
  float _486;
  float _487;
  float _488;
  [branch]
  if (!(((cb12_022x * _14.x) + cb12_022y) >= 1.0f)) {
    if (!(CustomPixelConsts_032.y < 0.5f)) {
      uint _69 = t3.Load(int3(_11, _12, 0));
      _79 = ((((float((uint)(uint)(_69.x)) * 0.003921568859368563f) + -1.0f) * saturate(CustomPixelConsts_032.x)) + 1.0f);
    } else {
      _79 = 1.0f;
    }
    float4 _81 = t1.Load(int3(_11, _12, 0));
    float _85 = _81.x * _79;
    float _86 = _81.y * _79;
    float _87 = _81.z * _79;
    if (!(CustomPixelConsts_032.y >= 0.5f)) {
      float4 _91 = t2.Load(int3(_11, _12, 0));
      _94 = _91.x;
    } else {
      _94 = _79;
    }
    float _102 = ((mad(cb12_213x, _14.x, mad(cb12_212x, _23, (cb12_211x * _22))) + cb12_214x) / _59) - cb12_000x;
    float _103 = ((mad(cb12_213y, _14.x, mad(cb12_212y, _23, (cb12_211y * _22))) + cb12_214y) / _59) - cb12_000y;
    float _104 = ((mad(cb12_213z, _14.x, mad(cb12_212z, _23, (cb12_211z * _22))) + cb12_214z) / _59) - cb12_000z;
    float _110 = sqrt(((_102 * _102) + (_103 * _103)) + (_104 * _104));
    float _125 = ((((CustomPixelConsts_000.w - CustomPixelConsts_000.z) * saturate((_110 - CustomPixelConsts_000.x) / (CustomPixelConsts_000.y - CustomPixelConsts_000.x))) + CustomPixelConsts_000.z) * (max(CustomPixelConsts_016.x, _94) + -1.0f)) + 1.0f;
    float _137 = _104 / _110;
    bool fog_current = ReceiverFrameMatches();
    float4 volume = fog_current ? SampleFogVolume(SV_Position.xy,_110) : 0.f;
    float _142 = min(cb12_042z, max(0.0f, (_110 - (fog_current ? FogFadeStart(cb12_022z) : cb12_022z))));
    float _143 = _142 * 0.0625f;
    float _144 = _143 * _137;
    float _145 = _143 * cb12_043x;
    float _150 = dot(float3(cb12_038x, cb12_038y, cb12_038z), float3((_102 / _110), (_103 / _110), _137));
    float _158 = (saturate((_150 + cb12_042x) / (cb12_042x + 1.0f)) * (cb12_043y - cb12_043z)) + cb12_043z;
    if (!(cb12_287z == 0)) {
      _167 = ((int)(_150 > 0.0f) && (int)(cb12_287z != 2));
    } else {
      _167 = true;
    }
    float _168 = abs(_150);
    if (_167) {
      _175 = saturate((_142 * 0.0020000000949949026f) + -0.30000001192092896f);
    } else {
      _175 = 1.0f;
    }
    float _176 = (_168 * _168) * _175;
    bool _177 = (_150 > 0.0f);
    if (_177) {
      _189 = cb12_039x;
      _190 = cb12_039y;
      _191 = cb12_039z;
    } else {
      _189 = cb12_041x;
      _190 = cb12_041y;
      _191 = cb12_041z;
    }
    float _202 = ((_189 - cb12_040x) * _176) + cb12_040x;
    float _203 = ((_190 - cb12_040y) * _176) + cb12_040y;
    float _204 = ((_191 - cb12_040z) * _176) + cb12_040z;
    if (_177) {
      _216 = cb12_045x;
      _217 = cb12_045y;
      _218 = cb12_045z;
    } else {
      _216 = cb12_047x;
      _217 = cb12_047y;
      _218 = cb12_047z;
    }
    [branch]
    if (fog_current) {
      _374 = saturate((_142 - cb12_048y) * cb12_048z);
      _373 = _374>1.e-7f ? pow(saturate(volume.a/_374),rcp(max(cb12_042w,.0001f))) : 0.f;
    } else {
      [branch]
      if (!(!(_142 >= cb12_048y))) {
        float _237 = (cb12_042y + cb12_000z) + (_137 * cb12_022z);
        float _238 = _158 * _237;
        float _239 = _158 * _144;
        _373 = (1.0f - ((((((((((((((((1.0f - saturate(_145 / (max(0.0f, ((_239 * 15.0f) + _238)) + 1.0f))) * (1.0f - saturate(_145 / (max(0.0f, ((_239 * 16.0f) + _238)) + 1.0f)))) * (1.0f - saturate(_145 / (max(0.0f, ((_239 * 14.0f) + _238)) + 1.0f)))) * (1.0f - saturate(_145 / (max(0.0f, ((_239 * 13.0f) + _238)) + 1.0f)))) * (1.0f - saturate(_145 / (max(0.0f, ((_239 * 12.0f) + _238)) + 1.0f)))) * (1.0f - saturate(_145 / (max(0.0f, ((_239 * 11.0f) + _238)) + 1.0f)))) * (1.0f - saturate(_145 / (max(0.0f, ((_239 * 10.0f) + _238)) + 1.0f)))) * (1.0f - saturate(_145 / (max(0.0f, ((_239 * 9.0f) + _238)) + 1.0f)))) * (1.0f - saturate(_145 / (max(0.0f, ((_239 * 8.0f) + _238)) + 1.0f)))) * (1.0f - saturate(_145 / (max(0.0f, ((_239 * 7.0f) + _238)) + 1.0f)))) * (1.0f - saturate(_145 / (max(0.0f, ((_239 * 6.0f) + _238)) + 1.0f)))) * (1.0f - saturate(_145 / (max(0.0f, ((_239 * 5.0f) + _238)) + 1.0f)))) * (1.0f - saturate(_145 / (max(0.0f, ((_239 * 4.0f) + _238)) + 1.0f)))) * (1.0f - saturate(_145 / (max(0.0f, ((_239 * 3.0f) + _238)) + 1.0f)))) * (1.0f - saturate(_145 / (max(0.0f, ((_239 * 2.0f) + _238)) + 1.0f)))) * (1.0f - saturate(_145 / (max(0.0f, (_158 * (_144 + _237))) + 1.0f)))));
        _374 = saturate((_142 - cb12_048y) * cb12_048z);
      } else {
        _373 = 1.0f;
        _374 = 0.0f;
      }
    }
    float _376 = log2(abs(_373));
    float _379 = exp2(_376 * cb12_042w) * _374;
    float _387 = saturate((cb12_190x * _379) + cb12_190y);
    float _400 = (cb12_189x - _202) * _387;
    float _401 = (cb12_189y - _203) * _387;
    float _402 = (cb12_189z - _204) * _387;
    float _403 = _400 + _202;
    float _404 = _401 + _203;
    float _405 = _402 + _204;
    float _411 = saturate((((cb12_189w + -1.0f) * saturate((cb12_190z * _379) + cb12_190w)) + 1.0f) * _379);
    [branch]
    if (cb12_193x > 0.0f) {
      float _421 = saturate((cb12_192x * _379) + cb12_192y);
      _456 = (((((cb12_191x - _202) * _421) - _400) * cb12_193x) + _403);
      _457 = (((((cb12_191y - _203) * _421) - _401) * cb12_193x) + _404);
      _458 = (((((cb12_191z - _204) * _421) - _402) * cb12_193x) + _405);
      _459 = (((saturate((((cb12_191w + -1.0f) * saturate((cb12_192z * _379) + cb12_192w)) + 1.0f) * _379) - _411) * cb12_193x) + _411);
    } else {
      _456 = _403;
      _457 = _404;
      _458 = _405;
      _459 = _411;
    }
    float _460 = _459 * _125 * (fog_current?FogAmount():1.f);
    float _462 = (_374 * _125) * exp2(_376 * cb12_048x) * (fog_current?FogAmount():1.f);
    float _463 = dot(float3(0.3330000042915344f, 0.5550000071525574f, 0.22200000286102295f), float3(_85, _86, _87));
    float _473 = (((_463 * (lerp(cb12_046x, _216, _176))) - _85) * _462) + _85;
    float _474 = (((_463 * (lerp(cb12_046y, _217, _176))) - _86) * _462) + _86;
    float _475 = (((_463 * (lerp(cb12_046z, _218, _176))) - _87) * _462) + _87;
    _486 = (lerp(_473, _456, _460));
    _487 = (lerp(_474, _457, _460));
    _488 = (lerp(_475, _458, _460));
    float3 direct = volume.rgb * (_379 > 1.e-7f ? _459/_379 : 0.f) * _125;
    _486 += direct.x; _487 += direct.y; _488 += direct.z;
  } else {
    _486 = 0.0f;
    _487 = 0.0f;
    _488 = 0.0f;
  }
  SV_Target.x = _486;
  SV_Target.y = _487;
  SV_Target.z = _488;
  SV_Target.w = 1.0f;
  return SV_Target;
}
