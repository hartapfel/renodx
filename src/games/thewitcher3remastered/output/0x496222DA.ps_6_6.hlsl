#include "../output.hlsli"

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

cbuffer cb12 : register(b12) {
  float cb12_221w : packoffset(c221.w);
  uint cb12_padding : packoffset(c340.w);
};

SamplerState s1 : register(s1);

struct OutputSignature {
  float4 SV_Target : SV_Target;
  float4 SV_Target_1 : SV_Target1;
  float4 SV_Target_2 : SV_Target2;
  float4 SV_Target_3 : SV_Target3;
};

OutputSignature main(
  noperspective float4 SV_Position : SV_Position,
  linear float2 TEXCOORD : TEXCOORD
) {
  float4 SV_Target = 0;
  float4 SV_Target_1 = 0;
  float4 SV_Target_2 = 0;
  float4 SV_Target_3 = 0;
  float _16 = SV_Position.x - CustomPixelConsts_016.x;
  float _17 = SV_Position.y - CustomPixelConsts_016.y;
  int _18 = int(_16);
  int _19 = int(_17);
  bool _30 = (CustomPixelConsts_112.x > 0.0f);
  uint _34 = uint(CustomPixelConsts_112.w);
  float4 _78 = t1.Load(int3(_18, _19, 0));
  float4 _85 = t0.SampleLevel(s1, float2(TEXCOORD.x, TEXCOORD.y), 0.0f);
  // RenoDX: preserve the native display adjustment and secondary SDR output
  // on a proxy. Reconstruct scene HDR before the primary HDR/UI composition.
  WitcherGradeState grade_state = (WitcherGradeState)0;
  if (WitcherUsePsychoV30()) {
    grade_state = WitcherPrepareGrade(WitcherSignedPow(_85.rgb, CustomPixelConsts_032.x));
    _85.rgb = WitcherSignedPow(grade_state.neutral_sdr, rcp(max(CustomPixelConsts_032.x, 1e-6f)));
  }
  bool _90 = (CustomPixelConsts_272.w > 0.0f);
  float _140;
  float _141;
  float _142;
  float _233;
  float _234;
  float _235;
  float _281;
  float _282;
  float _283;
  float _284;
  float _285;
  float _286;
  float _478;
  float _495;
  float _511;
  float _530;
  float _546;
  float _565;
  float _582;
  float _598;
  float _618;
  float _634;
  float _655;
  float _671;
  float _687;
  float _705;
  float _721;
  float _736;
  float _752;
  float _768;
  float _786;
  float _802;
  float _823;
  float _839;
  float _855;
  float _873;
  float _889;
  float _904;
  float _920;
  float _936;
  float _954;
  float _970;
  float _1025;
  float _1026;
  float _1027;
  float _1075;
  float _1076;
  float _1077;
  float _1100;
  int _1101;
  float _1102;
  float _1103;
  float _1104;
  float _1265;
  float _1283;
  float _1299;
  float _1318;
  float _1334;
  float _1353;
  float _1370;
  float _1386;
  float _1406;
  float _1422;
  float _1443;
  float _1459;
  float _1475;
  float _1493;
  float _1509;
  float _1524;
  float _1540;
  float _1556;
  float _1574;
  float _1590;
  float _1611;
  float _1627;
  float _1643;
  float _1661;
  float _1677;
  float _1692;
  float _1708;
  float _1724;
  float _1742;
  float _1758;
  float _1813;
  float _1814;
  float _1815;
  float _1866;
  float _1890;
  float _1891;
  float _1892;
  float _1908;
  float _1909;
  float _1910;
  float _1911;
  float _2075;
  float _2093;
  float _2109;
  float _2128;
  float _2144;
  float _2163;
  float _2180;
  float _2196;
  float _2216;
  float _2232;
  float _2253;
  float _2269;
  float _2285;
  float _2303;
  float _2319;
  float _2334;
  float _2350;
  float _2366;
  float _2385;
  float _2400;
  float _2422;
  float _2437;
  float _2453;
  float _2472;
  float _2487;
  float _2503;
  float _2518;
  float _2534;
  float _2553;
  float _2568;
  float _2623;
  float _2624;
  float _2625;
  float _2676;
  float _2700;
  float _2701;
  float _2702;
  if (_90) {
    float _93 = _85.x + -0.5f;
    float _94 = _85.y + -0.5f;
    float _95 = _85.z + -0.5f;
    float _96 = CustomPixelConsts_272.w * 0.1120000034570694f;
    float _97 = _96 + 1.0f;
    float _98 = _93 * _97;
    float _99 = _94 * _97;
    float _100 = _95 * _97;
    float _101 = CustomPixelConsts_272.w * 0.07500000298023224f;
    float _102 = 0.5f - _101;
    float _103 = _98 + _102;
    float _104 = _99 + _102;
    float _105 = _100 + _102;
    uint _106 = uint(CustomPixelConsts_272.x);
    float _107 = _103 * 17.882400512695312f;
    float _108 = _104 * 43.5161018371582f;
    float _109 = _107 + _108;
    float _110 = _105 * 4.119349956512451f;
    float _111 = _109 + _110;
    float _112 = _103 * 3.4556500911712646f;
    float _113 = _104 * 27.155399322509766f;
    float _114 = _112 + _113;
    float _115 = _105 * 3.867140054702759f;
    float _116 = _114 + _115;
    float _117 = _103 * 0.029956599697470665f;
    float _118 = _104 * 0.1843090057373047f;
    float _119 = _117 + _118;
    float _120 = _105 * 1.4670900106430054f;
    float _121 = _119 + _120;
    bool _122 = (_106 == 0);
    if (_122) {
      float _124 = _116 * 2.023439884185791f;
      float _125 = _121 * 2.52810001373291f;
      float _126 = _124 - _125;
      _140 = _126;
      _141 = _116;
      _142 = _121;
    } else {
      bool _128 = (_106 == 1);
      if (_128) {
        float _130 = _111 * 0.4942069947719574f;
        float _131 = _121 * 1.248270034790039f;
        float _132 = _130 + _131;
        _140 = _111;
        _141 = _132;
        _142 = _121;
      } else {
        bool _134 = (_106 == 2);
        if (_134) {
          float _136 = _111 * 0.3959130048751831f;
          float _137 = _116 * 0.8011090159416199f;
          float _138 = _137 - _136;
          _140 = _111;
          _141 = _116;
          _142 = _138;
        } else {
          _140 = _111;
          _141 = _116;
          _142 = _121;
        }
      }
    }
    float _143 = _140 * 0.08094444870948792f;
    float _144 = _141 * 0.13050441443920135f;
    float _145 = _142 * 0.11672106385231018f;
    float _146 = _140 * 0.010248533450067043f;
    float _147 = _142 * 0.11361470818519592f;
    float _148 = _140 * 0.0003652969317045063f;
    float _149 = _142 * 0.693511426448822f;
    float _150 = _103 - _143;
    float _151 = _150 + _144;
    float _152 = _151 - _145;
    float _153 = _141 * 0.05401932820677757f;
    float _154 = _141 * 0.004121614620089531f;
    float _155 = _152 * 0.699999988079071f;
    float _156 = _104 * 2.0f;
    float _157 = _146 + _156;
    float _158 = _157 - _153;
    float _159 = _158 + _147;
    float _160 = _159 + _155;
    float _161 = _105 * 2.0f;
    float _162 = _148 + _161;
    float _163 = _162 + _154;
    float _164 = _163 - _149;
    float _165 = _164 + _155;
    float _166 = saturate(_103);
    float _167 = saturate(_160);
    float _168 = saturate(_165);
    float _169 = _166 * CustomPixelConsts_272.w;
    float _170 = _167 * CustomPixelConsts_272.w;
    float _171 = _168 * CustomPixelConsts_272.w;
    float _172 = 1.0f - CustomPixelConsts_272.w;
    float _173 = _103 * _172;
    float _174 = _104 * _172;
    float _175 = _105 * _172;
    float _176 = _173 + -0.5f;
    float _177 = _176 + _169;
    float _178 = _174 + -0.5f;
    float _179 = _178 + _170;
    float _180 = _175 + -0.5f;
    float _181 = _180 + _171;
    float _182 = CustomPixelConsts_272.y + 1.0f;
    float _183 = _177 * _182;
    float _184 = _179 * _182;
    float _185 = _181 * _182;
    float _186 = CustomPixelConsts_272.w * 0.07999999821186066f;
    float _187 = CustomPixelConsts_272.z + 0.5f;
    float _188 = _187 + _186;
    float _189 = _183 + _188;
    float _190 = _184 + _188;
    float _191 = _185 + _188;
    float _192 = _78.x + -0.5f;
    float _193 = _78.y + -0.5f;
    float _194 = _78.z + -0.5f;
    float _195 = _192 * _97;
    float _196 = _193 * _97;
    float _197 = _194 * _97;
    float _198 = _195 + _102;
    float _199 = _196 + _102;
    float _200 = _197 + _102;
    float _201 = _198 * 17.882400512695312f;
    float _202 = _199 * 43.5161018371582f;
    float _203 = _201 + _202;
    float _204 = _200 * 4.119349956512451f;
    float _205 = _203 + _204;
    float _206 = _198 * 3.4556500911712646f;
    float _207 = _199 * 27.155399322509766f;
    float _208 = _206 + _207;
    float _209 = _200 * 3.867140054702759f;
    float _210 = _208 + _209;
    float _211 = _198 * 0.029956599697470665f;
    float _212 = _199 * 0.1843090057373047f;
    float _213 = _211 + _212;
    float _214 = _200 * 1.4670900106430054f;
    float _215 = _213 + _214;
    if (_122) {
      float _217 = _210 * 2.023439884185791f;
      float _218 = _215 * 2.52810001373291f;
      float _219 = _217 - _218;
      _233 = _219;
      _234 = _210;
      _235 = _215;
    } else {
      bool _221 = (_106 == 1);
      if (_221) {
        float _223 = _205 * 0.4942069947719574f;
        float _224 = _215 * 1.248270034790039f;
        float _225 = _223 + _224;
        _233 = _205;
        _234 = _225;
        _235 = _215;
      } else {
        bool _227 = (_106 == 2);
        if (_227) {
          float _229 = _205 * 0.3959130048751831f;
          float _230 = _210 * 0.8011090159416199f;
          float _231 = _230 - _229;
          _233 = _205;
          _234 = _210;
          _235 = _231;
        } else {
          _233 = _205;
          _234 = _210;
          _235 = _215;
        }
      }
    }
    float _236 = _233 * 0.08094444870948792f;
    float _237 = _234 * 0.13050441443920135f;
    float _238 = _235 * 0.11672106385231018f;
    float _239 = _233 * 0.010248533450067043f;
    float _240 = _235 * 0.11361470818519592f;
    float _241 = _233 * 0.0003652969317045063f;
    float _242 = _235 * 0.693511426448822f;
    float _243 = _198 - _236;
    float _244 = _243 + _237;
    float _245 = _244 - _238;
    float _246 = _234 * 0.05401932820677757f;
    float _247 = _234 * 0.004121614620089531f;
    float _248 = _245 * 0.699999988079071f;
    float _249 = _199 * 2.0f;
    float _250 = _239 + _249;
    float _251 = _250 - _246;
    float _252 = _251 + _240;
    float _253 = _252 + _248;
    float _254 = _200 * 2.0f;
    float _255 = _241 + _254;
    float _256 = _255 + _247;
    float _257 = _256 - _242;
    float _258 = _257 + _248;
    float _259 = saturate(_198);
    float _260 = saturate(_253);
    float _261 = saturate(_258);
    float _262 = _259 * CustomPixelConsts_272.w;
    float _263 = _260 * CustomPixelConsts_272.w;
    float _264 = _261 * CustomPixelConsts_272.w;
    float _265 = _198 * _172;
    float _266 = _199 * _172;
    float _267 = _200 * _172;
    float _268 = _265 + -0.5f;
    float _269 = _268 + _262;
    float _270 = _266 + -0.5f;
    float _271 = _270 + _263;
    float _272 = _267 + -0.5f;
    float _273 = _272 + _264;
    float _274 = _269 * _182;
    float _275 = _271 * _182;
    float _276 = _273 * _182;
    float _277 = _274 + _188;
    float _278 = _275 + _188;
    float _279 = _276 + _188;
    _281 = _277;
    _282 = _278;
    _283 = _279;
    _284 = _189;
    _285 = _190;
    _286 = _191;
  } else {
    _281 = _78.x;
    _282 = _78.y;
    _283 = _78.z;
    _284 = _85.x;
    _285 = _85.y;
    _286 = _85.z;
  }
  float _287 = log2(_281);
  float _288 = log2(_282);
  float _289 = log2(_283);
  float _290 = _287 * CustomPixelConsts_032.x;
  float _291 = _288 * CustomPixelConsts_032.x;
  float _292 = _289 * CustomPixelConsts_032.x;
  float _293 = exp2(_290);
  float _294 = exp2(_291);
  float _295 = exp2(_292);
  float _296 = log2(_284);
  float _297 = log2(_285);
  float _298 = log2(_286);
  float _299 = _296 * CustomPixelConsts_032.x;
  float _300 = _297 * CustomPixelConsts_032.x;
  float _301 = _298 * CustomPixelConsts_032.x;
  float _302 = exp2(_299);
  float _303 = exp2(_300);
  float _304 = exp2(_301);
  float _305 = _293 - _302;
  float _306 = _294 - _303;
  float _307 = _295 - _304;
  float _308 = _78.w - _85.w;
  float _309 = _305 * _78.w;
  float _310 = _306 * _78.w;
  float _311 = _307 * _78.w;
  float _312 = _308 * _78.w;
  float _313 = _309 + _302;
  float _314 = _310 + _303;
  float _315 = _311 + _304;
  float _316 = _312 + _85.w;
  float _317 = log2(_313);
  float _318 = log2(_314);
  float _319 = log2(_315);
  float _320 = log2(_316);
  float _321 = _317 * CustomPixelConsts_032.z;
  float _322 = _318 * CustomPixelConsts_032.z;
  float _323 = _319 * CustomPixelConsts_032.z;
  float _324 = _320 * CustomPixelConsts_032.z;
  float _325 = exp2(_321);
  float _326 = exp2(_322);
  float _327 = exp2(_323);
  float _328 = exp2(_324);
  if (WitcherUsePsychoV30()) {
    float3 scene_hdr = WitcherRestoreGrade(float3(_302, _303, _304), grade_state);
    _302 = scene_hdr.x;
    _303 = scene_hdr.y;
    _304 = scene_hdr.z;
  }
  bool _330 = (CustomPixelConsts_016.z > 0.0f);
  float _336 = _78.w * 2.0f;
  float _337 = saturate(_336);
  float _338 = _337 * -0.6699999570846558f;
  float _339 = _338 * _302;
  float _340 = _338 * _303;
  float _341 = _338 * _304;
  float _342 = _339 + _302;
  float _343 = _340 + _303;
  float _344 = _341 + _304;
  if (_330) {
    float _346 = float((int)(_18));
    float _347 = float((int)(_19));
    float _348 = CustomPixelConsts_048.z + CustomPixelConsts_048.x;
    float _349 = CustomPixelConsts_048.w + CustomPixelConsts_048.y;
    bool _350 = (_346 < _348);
    bool _351 = (_347 < _349);
    bool _352 = (_346 >= CustomPixelConsts_048.x);
    bool _353 = (_347 >= CustomPixelConsts_048.y);
    bool _354 = _352 && _350;
    bool _355 = _353 && _351;
    bool _356 = _354 && _355;
    if (_356) {
      float _358 = _346 - CustomPixelConsts_048.x;
      float _359 = _347 - CustomPixelConsts_048.y;
      float _360 = _358 / CustomPixelConsts_048.z;
      float _361 = _359 / CustomPixelConsts_048.w;
      float4 _363 = t2.SampleLevel(s1, float2(_360, _361), 0.0f);
      float _367 = _363.x * CustomPixelConsts_112.y;
      float _368 = _363.y * CustomPixelConsts_112.y;
      float _369 = _363.z * CustomPixelConsts_112.y;
      float _370 = dot(float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f), float3(_367, _368, _369));
      float _371 = abs(_370);
      bool _372 = (_34 == 0);
      // The optional regional texture also contains exposed scene RGB.
      // Preserve HDR here too, so the selected scene is tone-mapped only once.
      if (WitcherUsePsychoV30()) {
        float3 regional_hdr = WitcherSignedPow(
            float3(_367, _368, _369),
            rcp(max(CustomPixelConsts_032.x, 1e-6f)));
        _1075 = regional_hdr.x;
        _1076 = regional_hdr.y;
        _1077 = regional_hdr.z;
      } else if (_372) {
        float _374 = _367 * CustomPixelConsts_208.x;
        float _375 = _368 * CustomPixelConsts_208.x;
        float _376 = _369 * CustomPixelConsts_208.x;
        float _377 = CustomPixelConsts_208.z * CustomPixelConsts_208.y;
        float _378 = _374 + _377;
        float _379 = _375 + _377;
        float _380 = _376 + _377;
        float _381 = _378 * _367;
        float _382 = _379 * _368;
        float _383 = _380 * _369;
        float _384 = CustomPixelConsts_224.x * CustomPixelConsts_224.y;
        float _385 = _381 + _384;
        float _386 = _382 + _384;
        float _387 = _383 + _384;
        float _388 = _374 + CustomPixelConsts_208.y;
        float _389 = _375 + CustomPixelConsts_208.y;
        float _390 = _376 + CustomPixelConsts_208.y;
        float _391 = _388 * _367;
        float _392 = _389 * _368;
        float _393 = _390 * _369;
        float _394 = CustomPixelConsts_224.x * CustomPixelConsts_224.z;
        float _395 = _391 + _394;
        float _396 = _392 + _394;
        float _397 = _393 + _394;
        float _398 = _385 / _395;
        float _399 = _386 / _396;
        float _400 = _387 / _397;
        float _401 = CustomPixelConsts_224.y / CustomPixelConsts_224.z;
        float _402 = _398 - _401;
        float _403 = _399 - _401;
        float _404 = _400 - _401;
        float _405 = max(0.0f, _402);
        float _406 = max(0.0f, _403);
        float _407 = max(0.0f, _404);
        float _408 = _405 * 0.7599999904632568f;
        float _409 = _406 * 0.7599999904632568f;
        float _410 = _407 * 0.7599999904632568f;
        float _411 = CustomPixelConsts_208.x * 11.199999809265137f;
        float _412 = _411 + _377;
        float _413 = _412 * 11.199999809265137f;
        float _414 = _413 + _384;
        float _415 = _411 + CustomPixelConsts_208.y;
        float _416 = _415 * 11.199999809265137f;
        float _417 = _416 + _394;
        float _418 = _414 / _417;
        float _419 = _418 - _401;
        float _420 = max(0.0f, _419);
        float _421 = _408 / _420;
        float _422 = _409 / _420;
        float _423 = _410 / _420;
        _1075 = _421;
        _1076 = _422;
        _1077 = _423;
      } else {
        bool _425 = (_34 == 1);
        if (_425) {
          float _427 = CustomPixelConsts_224.w * 0.0009765625f;
          float _428 = log2(_427);
          float _429 = CustomPixelConsts_224.w * 90.5096664428711f;
          float _430 = log2(_429);
          float _431 = _367 * 0.8424790501594543f;
          float _432 = mad(_368, 0.07843360304832458f, _431);
          float _433 = mad(_369, 0.07922374457120895f, _432);
          float _434 = _367 * 0.04232824221253395f;
          float _435 = mad(_368, 0.8784686326980591f, _434);
          float _436 = mad(_369, 0.07916612923145294f, _435);
          float _437 = _367 * 0.042375653982162476f;
          float _438 = mad(_368, 0.07843360304832458f, _437);
          float _439 = mad(_369, 0.8791429996490479f, _438);
          float _440 = log2(_433);
          float _441 = log2(_436);
          float _442 = log2(_439);
          float _443 = max(_440, _428);
          float _444 = max(_441, _428);
          float _445 = max(_442, _428);
          float _446 = min(_443, _430);
          float _447 = min(_444, _430);
          float _448 = min(_445, _430);
          float _449 = _446 - _428;
          float _450 = _447 - _428;
          float _451 = _448 - _428;
          float _452 = _430 - _428;
          float _453 = _449 / _452;
          float _454 = _450 / _452;
          float _455 = _451 / _452;
          bool _458 = (cb12_221w > 0.0f);
          [branch]
          if (_458) {
            float _460 = -1.0f / CustomPixelConsts_256.x;
            float _461 = 1.0f - CustomPixelConsts_240.w;
            float _462 = _461 * CustomPixelConsts_240.x;
            float _463 = _462 * 2.0f;
            bool _464 = (_463 == 0.0f);
            if (!_464) {
              bool _466 = (_463 > 0.0f);
              bool _467 = (_463 < 0.0f);
              int _468 = (int)(uint)(_466);
              int _469 = (int)(uint)(_467);
              int _470 = _468 - _469;
              float _471 = float((int)(_470));
              float _472 = abs(_463);
              float _473 = log2(_472);
              float _474 = _473 * CustomPixelConsts_256.x;
              float _475 = exp2(_474);
              float _476 = _475 * _471;
              _478 = _476;
            } else {
              _478 = 0.0f;
            }
            float _479 = _478 + -1.0f;
            bool _480 = (_462 == 0.0f);
            if (!_480) {
              bool _482 = (_462 > 0.0f);
              bool _483 = (_462 < 0.0f);
              int _484 = (int)(uint)(_482);
              int _485 = (int)(uint)(_483);
              int _486 = _484 - _485;
              float _487 = float((int)(_486));
              float _488 = abs(_462);
              float _489 = log2(_488);
              float _490 = CustomPixelConsts_256.x * _489;
              float _491 = -0.0f - _490;
              float _492 = exp2(_491);
              float _493 = _492 * _487;
              _495 = _493;
            } else {
              _495 = 0.0f;
            }
            float _496 = _495 * _479;
            bool _497 = (_496 == 0.0f);
            if (!_497) {
              bool _499 = (_496 > 0.0f);
              bool _500 = (_496 < 0.0f);
              int _501 = (int)(uint)(_499);
              int _502 = (int)(uint)(_500);
              int _503 = _501 - _502;
              float _504 = float((int)(_503));
              float _505 = abs(_496);
              float _506 = log2(_505);
              float _507 = _506 * _460;
              float _508 = exp2(_507);
              float _509 = _508 * _504;
              _511 = _509;
            } else {
              _511 = 0.0f;
            }
            float _512 = _453 - CustomPixelConsts_240.w;
            float _513 = _512 * CustomPixelConsts_240.x;
            float _514 = _513 / _511;
            float _515 = 1.0f / CustomPixelConsts_256.x;
            bool _516 = (_514 == 0.0f);
            if (!_516) {
              bool _518 = (_514 > 0.0f);
              bool _519 = (_514 < 0.0f);
              int _520 = (int)(uint)(_518);
              int _521 = (int)(uint)(_519);
              int _522 = _520 - _521;
              float _523 = float((int)(_522));
              float _524 = abs(_514);
              float _525 = log2(_524);
              float _526 = _525 * CustomPixelConsts_256.x;
              float _527 = exp2(_526);
              float _528 = _527 * _523;
              _530 = _528;
            } else {
              _530 = 0.0f;
            }
            float _531 = _530 + 1.0f;
            bool _532 = (_531 == 0.0f);
            if (!_532) {
              bool _534 = (_531 > 0.0f);
              bool _535 = (_531 < 0.0f);
              int _536 = (int)(uint)(_534);
              int _537 = (int)(uint)(_535);
              int _538 = _536 - _537;
              float _539 = float((int)(_538));
              float _540 = abs(_531);
              float _541 = log2(_540);
              float _542 = _541 * _515;
              float _543 = exp2(_542);
              float _544 = _543 * _539;
              _546 = _544;
            } else {
              _546 = 0.0f;
            }
            float _547 = _514 / _546;
            float _548 = -1.0f / CustomPixelConsts_240.y;
            float _549 = CustomPixelConsts_240.x * CustomPixelConsts_240.w;
            float _550 = _549 * 2.0f;
            bool _551 = (_550 == 0.0f);
            if (!_551) {
              bool _553 = (_550 > 0.0f);
              bool _554 = (_550 < 0.0f);
              int _555 = (int)(uint)(_553);
              int _556 = (int)(uint)(_554);
              int _557 = _555 - _556;
              float _558 = float((int)(_557));
              float _559 = abs(_550);
              float _560 = log2(_559);
              float _561 = _560 * CustomPixelConsts_240.y;
              float _562 = exp2(_561);
              float _563 = _562 * _558;
              _565 = _563;
            } else {
              _565 = 0.0f;
            }
            float _566 = _565 + -1.0f;
            bool _567 = (_549 == 0.0f);
            if (!_567) {
              bool _569 = (_549 > 0.0f);
              bool _570 = (_549 < 0.0f);
              int _571 = (int)(uint)(_569);
              int _572 = (int)(uint)(_570);
              int _573 = _571 - _572;
              float _574 = float((int)(_573));
              float _575 = abs(_549);
              float _576 = log2(_575);
              float _577 = CustomPixelConsts_240.y * _576;
              float _578 = -0.0f - _577;
              float _579 = exp2(_578);
              float _580 = _579 * _574;
              _582 = _580;
            } else {
              _582 = 0.0f;
            }
            float _583 = _582 * _566;
            bool _584 = (_583 == 0.0f);
            if (!_584) {
              bool _586 = (_583 > 0.0f);
              bool _587 = (_583 < 0.0f);
              int _588 = (int)(uint)(_586);
              int _589 = (int)(uint)(_587);
              int _590 = _588 - _589;
              float _591 = float((int)(_590));
              float _592 = abs(_583);
              float _593 = log2(_592);
              float _594 = _593 * _548;
              float _595 = exp2(_594);
              float _596 = _595 * _591;
              _598 = _596;
            } else {
              _598 = 0.0f;
            }
            float _599 = 1.0f - CustomPixelConsts_240.z;
            float _600 = _598 * _599;
            float _601 = -0.0f - _600;
            float _602 = _513 / _601;
            float _603 = 1.0f / CustomPixelConsts_240.y;
            bool _604 = (_602 == 0.0f);
            if (!_604) {
              bool _606 = (_602 > 0.0f);
              bool _607 = (_602 < 0.0f);
              int _608 = (int)(uint)(_606);
              int _609 = (int)(uint)(_607);
              int _610 = _608 - _609;
              float _611 = float((int)(_610));
              float _612 = abs(_602);
              float _613 = log2(_612);
              float _614 = _613 * CustomPixelConsts_240.y;
              float _615 = exp2(_614);
              float _616 = _615 * _611;
              _618 = _616;
            } else {
              _618 = 0.0f;
            }
            float _619 = _618 + 1.0f;
            bool _620 = (_619 == 0.0f);
            if (!_620) {
              bool _622 = (_619 > 0.0f);
              bool _623 = (_619 < 0.0f);
              int _624 = (int)(uint)(_622);
              int _625 = (int)(uint)(_623);
              int _626 = _624 - _625;
              float _627 = float((int)(_626));
              float _628 = abs(_619);
              float _629 = log2(_628);
              float _630 = _629 * _603;
              float _631 = exp2(_630);
              float _632 = _631 * _627;
              _634 = _632;
            } else {
              _634 = 0.0f;
            }
            float _635 = _602 / _634;
            bool _636 = (_453 >= CustomPixelConsts_240.w);
            float _637 = _547 * _511;
            float _638 = _600 * _635;
            float _639 = -0.0f - _638;
            float _640 = select(_636, _637, _639);
            float _641 = _640 + 0.5f;
            if (!_464) {
              bool _643 = (_463 > 0.0f);
              bool _644 = (_463 < 0.0f);
              int _645 = (int)(uint)(_643);
              int _646 = (int)(uint)(_644);
              int _647 = _645 - _646;
              float _648 = float((int)(_647));
              float _649 = abs(_463);
              float _650 = log2(_649);
              float _651 = _650 * CustomPixelConsts_256.x;
              float _652 = exp2(_651);
              float _653 = _652 * _648;
              _655 = _653;
            } else {
              _655 = 0.0f;
            }
            float _656 = _655 + -1.0f;
            if (!_480) {
              bool _658 = (_462 > 0.0f);
              bool _659 = (_462 < 0.0f);
              int _660 = (int)(uint)(_658);
              int _661 = (int)(uint)(_659);
              int _662 = _660 - _661;
              float _663 = float((int)(_662));
              float _664 = abs(_462);
              float _665 = log2(_664);
              float _666 = CustomPixelConsts_256.x * _665;
              float _667 = -0.0f - _666;
              float _668 = exp2(_667);
              float _669 = _668 * _663;
              _671 = _669;
            } else {
              _671 = 0.0f;
            }
            float _672 = _671 * _656;
            bool _673 = (_672 == 0.0f);
            if (!_673) {
              bool _675 = (_672 > 0.0f);
              bool _676 = (_672 < 0.0f);
              int _677 = (int)(uint)(_675);
              int _678 = (int)(uint)(_676);
              int _679 = _677 - _678;
              float _680 = float((int)(_679));
              float _681 = abs(_672);
              float _682 = log2(_681);
              float _683 = _682 * _460;
              float _684 = exp2(_683);
              float _685 = _684 * _680;
              _687 = _685;
            } else {
              _687 = 0.0f;
            }
            float _688 = _454 - CustomPixelConsts_240.w;
            float _689 = _688 * CustomPixelConsts_240.x;
            float _690 = _689 / _687;
            bool _691 = (_690 == 0.0f);
            if (!_691) {
              bool _693 = (_690 > 0.0f);
              bool _694 = (_690 < 0.0f);
              int _695 = (int)(uint)(_693);
              int _696 = (int)(uint)(_694);
              int _697 = _695 - _696;
              float _698 = float((int)(_697));
              float _699 = abs(_690);
              float _700 = log2(_699);
              float _701 = _700 * CustomPixelConsts_256.x;
              float _702 = exp2(_701);
              float _703 = _702 * _698;
              _705 = _703;
            } else {
              _705 = 0.0f;
            }
            float _706 = _705 + 1.0f;
            bool _707 = (_706 == 0.0f);
            if (!_707) {
              bool _709 = (_706 > 0.0f);
              bool _710 = (_706 < 0.0f);
              int _711 = (int)(uint)(_709);
              int _712 = (int)(uint)(_710);
              int _713 = _711 - _712;
              float _714 = float((int)(_713));
              float _715 = abs(_706);
              float _716 = log2(_715);
              float _717 = _716 * _515;
              float _718 = exp2(_717);
              float _719 = _718 * _714;
              _721 = _719;
            } else {
              _721 = 0.0f;
            }
            float _722 = _690 / _721;
            if (!_551) {
              bool _724 = (_550 > 0.0f);
              bool _725 = (_550 < 0.0f);
              int _726 = (int)(uint)(_724);
              int _727 = (int)(uint)(_725);
              int _728 = _726 - _727;
              float _729 = float((int)(_728));
              float _730 = abs(_550);
              float _731 = log2(_730);
              float _732 = _731 * CustomPixelConsts_240.y;
              float _733 = exp2(_732);
              float _734 = _733 * _729;
              _736 = _734;
            } else {
              _736 = 0.0f;
            }
            float _737 = _736 + -1.0f;
            if (!_567) {
              bool _739 = (_549 > 0.0f);
              bool _740 = (_549 < 0.0f);
              int _741 = (int)(uint)(_739);
              int _742 = (int)(uint)(_740);
              int _743 = _741 - _742;
              float _744 = float((int)(_743));
              float _745 = abs(_549);
              float _746 = log2(_745);
              float _747 = CustomPixelConsts_240.y * _746;
              float _748 = -0.0f - _747;
              float _749 = exp2(_748);
              float _750 = _749 * _744;
              _752 = _750;
            } else {
              _752 = 0.0f;
            }
            float _753 = _752 * _737;
            bool _754 = (_753 == 0.0f);
            if (!_754) {
              bool _756 = (_753 > 0.0f);
              bool _757 = (_753 < 0.0f);
              int _758 = (int)(uint)(_756);
              int _759 = (int)(uint)(_757);
              int _760 = _758 - _759;
              float _761 = float((int)(_760));
              float _762 = abs(_753);
              float _763 = log2(_762);
              float _764 = _763 * _548;
              float _765 = exp2(_764);
              float _766 = _765 * _761;
              _768 = _766;
            } else {
              _768 = 0.0f;
            }
            float _769 = _768 * _599;
            float _770 = -0.0f - _769;
            float _771 = _689 / _770;
            bool _772 = (_771 == 0.0f);
            if (!_772) {
              bool _774 = (_771 > 0.0f);
              bool _775 = (_771 < 0.0f);
              int _776 = (int)(uint)(_774);
              int _777 = (int)(uint)(_775);
              int _778 = _776 - _777;
              float _779 = float((int)(_778));
              float _780 = abs(_771);
              float _781 = log2(_780);
              float _782 = _781 * CustomPixelConsts_240.y;
              float _783 = exp2(_782);
              float _784 = _783 * _779;
              _786 = _784;
            } else {
              _786 = 0.0f;
            }
            float _787 = _786 + 1.0f;
            bool _788 = (_787 == 0.0f);
            if (!_788) {
              bool _790 = (_787 > 0.0f);
              bool _791 = (_787 < 0.0f);
              int _792 = (int)(uint)(_790);
              int _793 = (int)(uint)(_791);
              int _794 = _792 - _793;
              float _795 = float((int)(_794));
              float _796 = abs(_787);
              float _797 = log2(_796);
              float _798 = _797 * _603;
              float _799 = exp2(_798);
              float _800 = _799 * _795;
              _802 = _800;
            } else {
              _802 = 0.0f;
            }
            float _803 = _771 / _802;
            bool _804 = (_454 >= CustomPixelConsts_240.w);
            float _805 = _722 * _687;
            float _806 = _769 * _803;
            float _807 = -0.0f - _806;
            float _808 = select(_804, _805, _807);
            float _809 = _808 + 0.5f;
            if (!_464) {
              bool _811 = (_463 > 0.0f);
              bool _812 = (_463 < 0.0f);
              int _813 = (int)(uint)(_811);
              int _814 = (int)(uint)(_812);
              int _815 = _813 - _814;
              float _816 = float((int)(_815));
              float _817 = abs(_463);
              float _818 = log2(_817);
              float _819 = _818 * CustomPixelConsts_256.x;
              float _820 = exp2(_819);
              float _821 = _820 * _816;
              _823 = _821;
            } else {
              _823 = 0.0f;
            }
            float _824 = _823 + -1.0f;
            if (!_480) {
              bool _826 = (_462 > 0.0f);
              bool _827 = (_462 < 0.0f);
              int _828 = (int)(uint)(_826);
              int _829 = (int)(uint)(_827);
              int _830 = _828 - _829;
              float _831 = float((int)(_830));
              float _832 = abs(_462);
              float _833 = log2(_832);
              float _834 = CustomPixelConsts_256.x * _833;
              float _835 = -0.0f - _834;
              float _836 = exp2(_835);
              float _837 = _836 * _831;
              _839 = _837;
            } else {
              _839 = 0.0f;
            }
            float _840 = _839 * _824;
            bool _841 = (_840 == 0.0f);
            if (!_841) {
              bool _843 = (_840 > 0.0f);
              bool _844 = (_840 < 0.0f);
              int _845 = (int)(uint)(_843);
              int _846 = (int)(uint)(_844);
              int _847 = _845 - _846;
              float _848 = float((int)(_847));
              float _849 = abs(_840);
              float _850 = log2(_849);
              float _851 = _850 * _460;
              float _852 = exp2(_851);
              float _853 = _852 * _848;
              _855 = _853;
            } else {
              _855 = 0.0f;
            }
            float _856 = _455 - CustomPixelConsts_240.w;
            float _857 = _856 * CustomPixelConsts_240.x;
            float _858 = _857 / _855;
            bool _859 = (_858 == 0.0f);
            if (!_859) {
              bool _861 = (_858 > 0.0f);
              bool _862 = (_858 < 0.0f);
              int _863 = (int)(uint)(_861);
              int _864 = (int)(uint)(_862);
              int _865 = _863 - _864;
              float _866 = float((int)(_865));
              float _867 = abs(_858);
              float _868 = log2(_867);
              float _869 = _868 * CustomPixelConsts_256.x;
              float _870 = exp2(_869);
              float _871 = _870 * _866;
              _873 = _871;
            } else {
              _873 = 0.0f;
            }
            float _874 = _873 + 1.0f;
            bool _875 = (_874 == 0.0f);
            if (!_875) {
              bool _877 = (_874 > 0.0f);
              bool _878 = (_874 < 0.0f);
              int _879 = (int)(uint)(_877);
              int _880 = (int)(uint)(_878);
              int _881 = _879 - _880;
              float _882 = float((int)(_881));
              float _883 = abs(_874);
              float _884 = log2(_883);
              float _885 = _884 * _515;
              float _886 = exp2(_885);
              float _887 = _886 * _882;
              _889 = _887;
            } else {
              _889 = 0.0f;
            }
            float _890 = _858 / _889;
            if (!_551) {
              bool _892 = (_550 > 0.0f);
              bool _893 = (_550 < 0.0f);
              int _894 = (int)(uint)(_892);
              int _895 = (int)(uint)(_893);
              int _896 = _894 - _895;
              float _897 = float((int)(_896));
              float _898 = abs(_550);
              float _899 = log2(_898);
              float _900 = _899 * CustomPixelConsts_240.y;
              float _901 = exp2(_900);
              float _902 = _901 * _897;
              _904 = _902;
            } else {
              _904 = 0.0f;
            }
            float _905 = _904 + -1.0f;
            if (!_567) {
              bool _907 = (_549 > 0.0f);
              bool _908 = (_549 < 0.0f);
              int _909 = (int)(uint)(_907);
              int _910 = (int)(uint)(_908);
              int _911 = _909 - _910;
              float _912 = float((int)(_911));
              float _913 = abs(_549);
              float _914 = log2(_913);
              float _915 = CustomPixelConsts_240.y * _914;
              float _916 = -0.0f - _915;
              float _917 = exp2(_916);
              float _918 = _917 * _912;
              _920 = _918;
            } else {
              _920 = 0.0f;
            }
            float _921 = _920 * _905;
            bool _922 = (_921 == 0.0f);
            if (!_922) {
              bool _924 = (_921 > 0.0f);
              bool _925 = (_921 < 0.0f);
              int _926 = (int)(uint)(_924);
              int _927 = (int)(uint)(_925);
              int _928 = _926 - _927;
              float _929 = float((int)(_928));
              float _930 = abs(_921);
              float _931 = log2(_930);
              float _932 = _931 * _548;
              float _933 = exp2(_932);
              float _934 = _933 * _929;
              _936 = _934;
            } else {
              _936 = 0.0f;
            }
            float _937 = _936 * _599;
            float _938 = -0.0f - _937;
            float _939 = _857 / _938;
            bool _940 = (_939 == 0.0f);
            if (!_940) {
              bool _942 = (_939 > 0.0f);
              bool _943 = (_939 < 0.0f);
              int _944 = (int)(uint)(_942);
              int _945 = (int)(uint)(_943);
              int _946 = _944 - _945;
              float _947 = float((int)(_946));
              float _948 = abs(_939);
              float _949 = log2(_948);
              float _950 = _949 * CustomPixelConsts_240.y;
              float _951 = exp2(_950);
              float _952 = _951 * _947;
              _954 = _952;
            } else {
              _954 = 0.0f;
            }
            float _955 = _954 + 1.0f;
            bool _956 = (_955 == 0.0f);
            if (!_956) {
              bool _958 = (_955 > 0.0f);
              bool _959 = (_955 < 0.0f);
              int _960 = (int)(uint)(_958);
              int _961 = (int)(uint)(_959);
              int _962 = _960 - _961;
              float _963 = float((int)(_962));
              float _964 = abs(_955);
              float _965 = log2(_964);
              float _966 = _965 * _603;
              float _967 = exp2(_966);
              float _968 = _967 * _963;
              _970 = _968;
            } else {
              _970 = 0.0f;
            }
            float _971 = _939 / _970;
            bool _972 = (_455 >= CustomPixelConsts_240.w);
            float _973 = _890 * _855;
            float _974 = _937 * _971;
            float _975 = -0.0f - _974;
            float _976 = select(_972, _973, _975);
            float _977 = _976 + 0.5f;
            _1025 = _641;
            _1026 = _809;
            _1027 = _977;
          } else {
            float _979 = _453 * _453;
            float _980 = _454 * _454;
            float _981 = _455 * _455;
            float _982 = _979 * _979;
            float _983 = _980 * _980;
            float _984 = _981 * _981;
            float _985 = _979 * 15.5f;
            float _986 = _980 * 15.5f;
            float _987 = _981 * 15.5f;
            float _988 = _453 * -40.13999938964844f;
            float _989 = _454 * -40.13999938964844f;
            float _990 = _455 * -40.13999938964844f;
            float _991 = _453 * 6.868000030517578f;
            float _992 = _991 * _979;
            float _993 = _454 * 6.868000030517578f;
            float _994 = _993 * _980;
            float _995 = _455 * 6.868000030517578f;
            float _996 = _995 * _981;
            float _997 = _979 * 0.42980000376701355f;
            float _998 = _980 * 0.42980000376701355f;
            float _999 = _981 * 0.42980000376701355f;
            float _1000 = _453 * 0.11909999698400497f;
            float _1001 = _454 * 0.11909999698400497f;
            float _1002 = _455 * 0.11909999698400497f;
            float _1003 = _985 + 31.959999084472656f;
            float _1004 = _1003 + _988;
            float _1005 = _982 * _1004;
            float _1006 = _1000 + -0.002319999970495701f;
            float _1007 = _1006 + _997;
            float _1008 = _1007 - _992;
            float _1009 = _1008 + _1005;
            float _1010 = _986 + 31.959999084472656f;
            float _1011 = _1010 + _989;
            float _1012 = _983 * _1011;
            float _1013 = _1001 + -0.002319999970495701f;
            float _1014 = _1013 + _998;
            float _1015 = _1014 - _994;
            float _1016 = _1015 + _1012;
            float _1017 = _987 + 31.959999084472656f;
            float _1018 = _1017 + _990;
            float _1019 = _984 * _1018;
            float _1020 = _1002 + -0.002319999970495701f;
            float _1021 = _1020 + _999;
            float _1022 = _1021 - _996;
            float _1023 = _1022 + _1019;
            _1025 = _1009;
            _1026 = _1016;
            _1027 = _1023;
          }
          float _1028 = _1025 * CustomPixelConsts_208.x;
          float _1029 = _1026 * CustomPixelConsts_208.y;
          float _1030 = _1027 * CustomPixelConsts_208.z;
          float _1031 = log2(_1028);
          float _1032 = log2(_1029);
          float _1033 = log2(_1030);
          float _1034 = _1031 * CustomPixelConsts_224.x;
          float _1035 = _1032 * CustomPixelConsts_224.y;
          float _1036 = _1033 * CustomPixelConsts_224.z;
          float _1037 = exp2(_1034);
          float _1038 = exp2(_1035);
          float _1039 = exp2(_1036);
          float _1040 = dot(float3(_1037, _1038, _1039), float3(0.2126729041337967f, 0.7151522040367126f, 0.07217500358819962f));
          float _1041 = _1037 - _1040;
          float _1042 = _1038 - _1040;
          float _1043 = _1039 - _1040;
          float _1044 = _1041 * CustomPixelConsts_208.w;
          float _1045 = _1042 * CustomPixelConsts_208.w;
          float _1046 = _1043 * CustomPixelConsts_208.w;
          float _1047 = _1044 + _1040;
          float _1048 = _1045 + _1040;
          float _1049 = _1046 + _1040;
          float _1050 = max(_1047, 0.0f);
          float _1051 = max(_1048, 0.0f);
          float _1052 = max(_1049, 0.0f);
          float _1053 = _1050 * 1.1968790292739868f;
          float _1054 = mad(_1051, -0.09802088141441345f, _1053);
          float _1055 = mad(_1052, -0.09902974218130112f, _1054);
          float _1056 = _1050 * -0.052896853536367416f;
          float _1057 = mad(_1051, 1.1519031524658203f, _1056);
          float _1058 = mad(_1052, -0.09896117448806763f, _1057);
          float _1059 = _1050 * -0.05297163501381874f;
          float _1060 = mad(_1051, -0.09804344922304153f, _1059);
          float _1061 = mad(_1052, 1.151073694229126f, _1060);
          float _1062 = max(_1055, 9.999999747378752e-05f);
          float _1063 = max(_1058, 9.999999747378752e-05f);
          float _1064 = max(_1061, 9.999999747378752e-05f);
          float _1065 = log2(_1062);
          float _1066 = log2(_1063);
          float _1067 = log2(_1064);
          float _1068 = _1065 * 2.200000047683716f;
          float _1069 = _1066 * 2.200000047683716f;
          float _1070 = _1067 * 2.200000047683716f;
          float _1071 = exp2(_1068);
          float _1072 = exp2(_1069);
          float _1073 = exp2(_1070);
          _1075 = _1071;
          _1076 = _1072;
          _1077 = _1073;
        } else {
          _1075 = 0.0f;
          _1076 = 0.0f;
          _1077 = 0.0f;
        }
      }
      float _1078 = _1075 * CustomPixelConsts_016.z;
      float _1079 = _1076 * CustomPixelConsts_016.z;
      float _1080 = _1077 * CustomPixelConsts_016.z;
      float _1081 = log2(_1078);
      float _1082 = log2(_1079);
      float _1083 = log2(_1080);
      float _1084 = _1081 * CustomPixelConsts_032.x;
      float _1085 = _1082 * CustomPixelConsts_032.x;
      float _1086 = _1083 * CustomPixelConsts_032.x;
      float _1087 = exp2(_1084);
      float _1088 = exp2(_1085);
      float _1089 = exp2(_1086);
      if (WitcherUsePsychoV30()) {
        float3 regional_hdr = WitcherSignedPow(float3(_1078, _1079, _1080), CustomPixelConsts_032.x);
        _1087 = regional_hdr.x;
        _1088 = regional_hdr.y;
        _1089 = regional_hdr.z;
      }
      float _1090 = _1087 - _342;
      float _1091 = _1088 - _343;
      float _1092 = _1089 - _344;
      float _1093 = _1090 * CustomPixelConsts_016.z;
      float _1094 = _1091 * CustomPixelConsts_016.z;
      float _1095 = _1092 * CustomPixelConsts_016.z;
      float _1096 = _1093 + _342;
      float _1097 = _1094 + _343;
      float _1098 = _1095 + _344;
      _1100 = _371;
      _1101 = 0;
      _1102 = _1096;
      _1103 = _1097;
      _1104 = _1098;
    } else {
      _1100 = _85.w;
      _1101 = 1;
      _1102 = _342;
      _1103 = _343;
      _1104 = _344;
    }
  } else {
    _1100 = _85.w;
    _1101 = 1;
    _1102 = _342;
    _1103 = _343;
    _1104 = _344;
  }
  float _1117 = _1102 * 0.627403974533081f;
  float _1118 = mad(0.3292819857597351f, _1103, _1117);
  float _1119 = mad(0.04331360012292862f, _1104, _1118);
  float _1120 = _1102 * 0.06909699738025665f;
  float _1121 = mad(0.9195399880409241f, _1103, _1120);
  float _1122 = mad(0.011361200362443924f, _1104, _1121);
  float _1123 = _1102 * 0.01639159955084324f;
  float _1124 = mad(0.08801320195198059f, _1103, _1123);
  float _1125 = mad(0.8955950140953064f, _1104, _1124);
  float _1126 = _1119 * CustomPixelConsts_064.x;
  float _1127 = mad(CustomPixelConsts_064.y, _1122, _1126);
  float _1128 = mad(CustomPixelConsts_064.z, _1125, _1127);
  float _1129 = _1119 * CustomPixelConsts_080.x;
  float _1130 = mad(CustomPixelConsts_080.y, _1122, _1129);
  float _1131 = mad(CustomPixelConsts_080.z, _1125, _1130);
  float _1132 = _1119 * CustomPixelConsts_096.x;
  float _1133 = mad(CustomPixelConsts_096.y, _1122, _1132);
  float _1134 = mad(CustomPixelConsts_096.z, _1125, _1133);
  float _1135 = WitcherUsePsychoV30() ? _1128 : saturate(_1128);
  float _1136 = WitcherUsePsychoV30() ? _1131 : saturate(_1131);
  float _1137 = WitcherUsePsychoV30() ? _1134 : saturate(_1134);
  float _1138 = _1135 - _1119;
  float _1139 = _1136 - _1122;
  float _1140 = _1137 - _1125;
  // Ignore the game's HDR Saturation matrix blend in the custom pipeline,
  // including UI and the FG scene-only output. Vanilla retains its setting.
  float native_hdr_saturation = WitcherUsePsychoV30() ? 0.f : CustomPixelConsts_000.z;
  float _1141 = _1138 * native_hdr_saturation;
  float _1142 = _1139 * native_hdr_saturation;
  float _1143 = _1140 * native_hdr_saturation;
  float _1144 = _1141 + _1119;
  float _1145 = _1142 + _1122;
  float _1146 = _1143 + _1125;
  if (WitcherUsePsychoV30()) {
    // All scene-side bloom, screen blending, LUT and display grading precede
    // the display map. Only UI composition and PQ encoding follow this point.
    // The native matrices above have already converted the scene to BT.2020.
    float3 mapped_bt2020 = WitcherToneMapOutput(float3(_1144, _1145, _1146), TEXCOORD);
    _1144 = mapped_bt2020.x;
    _1145 = mapped_bt2020.y;
    _1146 = mapped_bt2020.z;
  }
  float _1147 = _293 * 0.627403974533081f;
  float _1148 = mad(0.3292819857597351f, _294, _1147);
  float _1149 = mad(0.04331360012292862f, _295, _1148);
  float _1150 = _293 * 0.06909699738025665f;
  float _1151 = mad(0.9195399880409241f, _294, _1150);
  float _1152 = mad(0.011361200362443924f, _295, _1151);
  float _1153 = _293 * 0.01639159955084324f;
  float _1154 = mad(0.08801320195198059f, _294, _1153);
  float _1155 = mad(0.8955950140953064f, _295, _1154);
  float _1156 = _1149 * CustomPixelConsts_064.x;
  float _1157 = mad(CustomPixelConsts_064.y, _1152, _1156);
  float _1158 = mad(CustomPixelConsts_064.z, _1155, _1157);
  float _1159 = _1149 * CustomPixelConsts_080.x;
  float _1160 = mad(CustomPixelConsts_080.y, _1152, _1159);
  float _1161 = mad(CustomPixelConsts_080.z, _1155, _1160);
  float _1162 = _1149 * CustomPixelConsts_096.x;
  float _1163 = mad(CustomPixelConsts_096.y, _1152, _1162);
  float _1164 = mad(CustomPixelConsts_096.z, _1155, _1163);
  float _1165 = saturate(_1158);
  float _1166 = saturate(_1161);
  float _1167 = saturate(_1164);
  float _1168 = _1165 - _1149;
  float _1169 = _1166 - _1152;
  float _1170 = _1167 - _1155;
  float _1171 = _1168 * native_hdr_saturation;
  float _1172 = _1169 * native_hdr_saturation;
  float _1173 = _1170 * native_hdr_saturation;
  float _1174 = _1171 + _1149;
  float _1175 = _1172 + _1152;
  float _1176 = _1173 + _1155;
  if (WitcherUsePsychoV30()) {
    // Native UI is straight-alpha. Scene and UI have independent white levels.
    float ui_scale = RENODX_GRAPHICS_WHITE_NITS / RENODX_DIFFUSE_WHITE_NITS;
    _1174 *= ui_scale;
    _1175 *= ui_scale;
    _1176 *= ui_scale;
  }
  bool _1177 = (_1100 > CustomPixelConsts_032.w);
  bool _1178 = !WitcherUsePsychoV30() && _30 && _1177; // No native HDR expansion after PsychoV.
  if (_1178) {
    float _1180 = _1100 - CustomPixelConsts_032.w;
    float _1181 = CustomPixelConsts_112.z - CustomPixelConsts_032.w;
    float _1182 = _1180 / _1181;
    float _1183 = saturate(_1182);
    bool _1184 = (_34 == 0);
    if (_1184) {
      float _1186 = CustomPixelConsts_144.x * CustomPixelConsts_112.z;
      float _1187 = CustomPixelConsts_144.z * CustomPixelConsts_144.y;
      float _1188 = _1186 + _1187;
      float _1189 = _1188 * CustomPixelConsts_112.z;
      float _1190 = CustomPixelConsts_160.x * CustomPixelConsts_160.y;
      float _1191 = _1189 + _1190;
      float _1192 = _1186 + CustomPixelConsts_144.y;
      float _1193 = _1192 * CustomPixelConsts_112.z;
      float _1194 = CustomPixelConsts_160.x * CustomPixelConsts_160.z;
      float _1195 = _1193 + _1194;
      float _1196 = _1191 / _1195;
      float _1197 = CustomPixelConsts_160.y / CustomPixelConsts_160.z;
      float _1198 = _1196 - _1197;
      float _1199 = max(0.0f, _1198);
      float _1200 = CustomPixelConsts_144.x * 11.199999809265137f;
      float _1201 = _1200 + _1187;
      float _1202 = _1201 * 11.199999809265137f;
      float _1203 = _1202 + _1190;
      float _1204 = _1200 + CustomPixelConsts_144.y;
      float _1205 = _1204 * 11.199999809265137f;
      float _1206 = _1205 + _1194;
      float _1207 = _1203 / _1206;
      float _1208 = _1207 - _1197;
      float _1209 = max(0.0f, _1208);
      float _1210 = _1199 / _1209;
      _1866 = _1210;
    } else {
      bool _1212 = (_34 == 1);
      if (_1212) {
        float _1214 = CustomPixelConsts_160.w * 0.0009765625f;
        float _1215 = log2(_1214);
        float _1216 = CustomPixelConsts_160.w * 90.5096664428711f;
        float _1217 = log2(_1216);
        float _1218 = CustomPixelConsts_112.z * 0.8424790501594543f;
        float _1219 = mad(CustomPixelConsts_112.z, 0.07843360304832458f, _1218);
        float _1220 = mad(CustomPixelConsts_112.z, 0.07922374457120895f, _1219);
        float _1221 = CustomPixelConsts_112.z * 0.04232824221253395f;
        float _1222 = mad(CustomPixelConsts_112.z, 0.8784686326980591f, _1221);
        float _1223 = mad(CustomPixelConsts_112.z, 0.07916612923145294f, _1222);
        float _1224 = CustomPixelConsts_112.z * 0.042375653982162476f;
        float _1225 = mad(CustomPixelConsts_112.z, 0.07843360304832458f, _1224);
        float _1226 = mad(CustomPixelConsts_112.z, 0.8791429996490479f, _1225);
        float _1227 = log2(_1220);
        float _1228 = log2(_1223);
        float _1229 = log2(_1226);
        float _1230 = max(_1227, _1215);
        float _1231 = max(_1228, _1215);
        float _1232 = max(_1229, _1215);
        float _1233 = min(_1230, _1217);
        float _1234 = min(_1231, _1217);
        float _1235 = min(_1232, _1217);
        float _1236 = _1233 - _1215;
        float _1237 = _1234 - _1215;
        float _1238 = _1235 - _1215;
        float _1239 = _1217 - _1215;
        float _1240 = _1236 / _1239;
        float _1241 = _1237 / _1239;
        float _1242 = _1238 / _1239;
        bool _1245 = (cb12_221w > 0.0f);
        [branch]
        if (_1245) {
          float _1247 = -1.0f / CustomPixelConsts_192.x;
          float _1248 = 1.0f - CustomPixelConsts_176.w;
          float _1249 = CustomPixelConsts_176.x * 2.0f;
          float _1250 = _1249 * _1248;
          bool _1251 = (_1250 == 0.0f);
          if (!_1251) {
            bool _1253 = (_1250 > 0.0f);
            bool _1254 = (_1250 < 0.0f);
            int _1255 = (int)(uint)(_1253);
            int _1256 = (int)(uint)(_1254);
            int _1257 = _1255 - _1256;
            float _1258 = float((int)(_1257));
            float _1259 = abs(_1250);
            float _1260 = log2(_1259);
            float _1261 = _1260 * CustomPixelConsts_192.x;
            float _1262 = exp2(_1261);
            float _1263 = _1262 * _1258;
            _1265 = _1263;
          } else {
            _1265 = 0.0f;
          }
          float _1266 = _1265 + -1.0f;
          float _1267 = _1248 * CustomPixelConsts_176.x;
          bool _1268 = (_1267 == 0.0f);
          if (!_1268) {
            bool _1270 = (_1267 > 0.0f);
            bool _1271 = (_1267 < 0.0f);
            int _1272 = (int)(uint)(_1270);
            int _1273 = (int)(uint)(_1271);
            int _1274 = _1272 - _1273;
            float _1275 = float((int)(_1274));
            float _1276 = abs(_1267);
            float _1277 = log2(_1276);
            float _1278 = CustomPixelConsts_192.x * _1277;
            float _1279 = -0.0f - _1278;
            float _1280 = exp2(_1279);
            float _1281 = _1280 * _1275;
            _1283 = _1281;
          } else {
            _1283 = 0.0f;
          }
          float _1284 = _1283 * _1266;
          bool _1285 = (_1284 == 0.0f);
          if (!_1285) {
            bool _1287 = (_1284 > 0.0f);
            bool _1288 = (_1284 < 0.0f);
            int _1289 = (int)(uint)(_1287);
            int _1290 = (int)(uint)(_1288);
            int _1291 = _1289 - _1290;
            float _1292 = float((int)(_1291));
            float _1293 = abs(_1284);
            float _1294 = log2(_1293);
            float _1295 = _1294 * _1247;
            float _1296 = exp2(_1295);
            float _1297 = _1296 * _1292;
            _1299 = _1297;
          } else {
            _1299 = 0.0f;
          }
          float _1300 = _1240 - CustomPixelConsts_176.w;
          float _1301 = _1300 * CustomPixelConsts_176.x;
          float _1302 = _1301 / _1299;
          float _1303 = 1.0f / CustomPixelConsts_192.x;
          bool _1304 = (_1302 == 0.0f);
          if (!_1304) {
            bool _1306 = (_1302 > 0.0f);
            bool _1307 = (_1302 < 0.0f);
            int _1308 = (int)(uint)(_1306);
            int _1309 = (int)(uint)(_1307);
            int _1310 = _1308 - _1309;
            float _1311 = float((int)(_1310));
            float _1312 = abs(_1302);
            float _1313 = log2(_1312);
            float _1314 = _1313 * CustomPixelConsts_192.x;
            float _1315 = exp2(_1314);
            float _1316 = _1315 * _1311;
            _1318 = _1316;
          } else {
            _1318 = 0.0f;
          }
          float _1319 = _1318 + 1.0f;
          bool _1320 = (_1319 == 0.0f);
          if (!_1320) {
            bool _1322 = (_1319 > 0.0f);
            bool _1323 = (_1319 < 0.0f);
            int _1324 = (int)(uint)(_1322);
            int _1325 = (int)(uint)(_1323);
            int _1326 = _1324 - _1325;
            float _1327 = float((int)(_1326));
            float _1328 = abs(_1319);
            float _1329 = log2(_1328);
            float _1330 = _1329 * _1303;
            float _1331 = exp2(_1330);
            float _1332 = _1331 * _1327;
            _1334 = _1332;
          } else {
            _1334 = 0.0f;
          }
          float _1335 = _1302 / _1334;
          float _1336 = -1.0f / CustomPixelConsts_176.y;
          float _1337 = CustomPixelConsts_176.x * CustomPixelConsts_176.w;
          float _1338 = _1337 * 2.0f;
          bool _1339 = (_1338 == 0.0f);
          if (!_1339) {
            bool _1341 = (_1338 > 0.0f);
            bool _1342 = (_1338 < 0.0f);
            int _1343 = (int)(uint)(_1341);
            int _1344 = (int)(uint)(_1342);
            int _1345 = _1343 - _1344;
            float _1346 = float((int)(_1345));
            float _1347 = abs(_1338);
            float _1348 = log2(_1347);
            float _1349 = _1348 * CustomPixelConsts_176.y;
            float _1350 = exp2(_1349);
            float _1351 = _1350 * _1346;
            _1353 = _1351;
          } else {
            _1353 = 0.0f;
          }
          float _1354 = _1353 + -1.0f;
          bool _1355 = (_1337 == 0.0f);
          if (!_1355) {
            bool _1357 = (_1337 > 0.0f);
            bool _1358 = (_1337 < 0.0f);
            int _1359 = (int)(uint)(_1357);
            int _1360 = (int)(uint)(_1358);
            int _1361 = _1359 - _1360;
            float _1362 = float((int)(_1361));
            float _1363 = abs(_1337);
            float _1364 = log2(_1363);
            float _1365 = CustomPixelConsts_176.y * _1364;
            float _1366 = -0.0f - _1365;
            float _1367 = exp2(_1366);
            float _1368 = _1367 * _1362;
            _1370 = _1368;
          } else {
            _1370 = 0.0f;
          }
          float _1371 = _1370 * _1354;
          bool _1372 = (_1371 == 0.0f);
          if (!_1372) {
            bool _1374 = (_1371 > 0.0f);
            bool _1375 = (_1371 < 0.0f);
            int _1376 = (int)(uint)(_1374);
            int _1377 = (int)(uint)(_1375);
            int _1378 = _1376 - _1377;
            float _1379 = float((int)(_1378));
            float _1380 = abs(_1371);
            float _1381 = log2(_1380);
            float _1382 = _1381 * _1336;
            float _1383 = exp2(_1382);
            float _1384 = _1383 * _1379;
            _1386 = _1384;
          } else {
            _1386 = 0.0f;
          }
          float _1387 = 1.0f - CustomPixelConsts_176.z;
          float _1388 = _1386 * _1387;
          float _1389 = -0.0f - _1388;
          float _1390 = _1301 / _1389;
          float _1391 = 1.0f / CustomPixelConsts_176.y;
          bool _1392 = (_1390 == 0.0f);
          if (!_1392) {
            bool _1394 = (_1390 > 0.0f);
            bool _1395 = (_1390 < 0.0f);
            int _1396 = (int)(uint)(_1394);
            int _1397 = (int)(uint)(_1395);
            int _1398 = _1396 - _1397;
            float _1399 = float((int)(_1398));
            float _1400 = abs(_1390);
            float _1401 = log2(_1400);
            float _1402 = _1401 * CustomPixelConsts_176.y;
            float _1403 = exp2(_1402);
            float _1404 = _1403 * _1399;
            _1406 = _1404;
          } else {
            _1406 = 0.0f;
          }
          float _1407 = _1406 + 1.0f;
          bool _1408 = (_1407 == 0.0f);
          if (!_1408) {
            bool _1410 = (_1407 > 0.0f);
            bool _1411 = (_1407 < 0.0f);
            int _1412 = (int)(uint)(_1410);
            int _1413 = (int)(uint)(_1411);
            int _1414 = _1412 - _1413;
            float _1415 = float((int)(_1414));
            float _1416 = abs(_1407);
            float _1417 = log2(_1416);
            float _1418 = _1417 * _1391;
            float _1419 = exp2(_1418);
            float _1420 = _1419 * _1415;
            _1422 = _1420;
          } else {
            _1422 = 0.0f;
          }
          float _1423 = _1390 / _1422;
          bool _1424 = (_1240 >= CustomPixelConsts_176.w);
          float _1425 = _1335 * _1299;
          float _1426 = _1388 * _1423;
          float _1427 = -0.0f - _1426;
          float _1428 = select(_1424, _1425, _1427);
          float _1429 = _1428 + 0.5f;
          if (!_1251) {
            bool _1431 = (_1250 > 0.0f);
            bool _1432 = (_1250 < 0.0f);
            int _1433 = (int)(uint)(_1431);
            int _1434 = (int)(uint)(_1432);
            int _1435 = _1433 - _1434;
            float _1436 = float((int)(_1435));
            float _1437 = abs(_1250);
            float _1438 = log2(_1437);
            float _1439 = _1438 * CustomPixelConsts_192.x;
            float _1440 = exp2(_1439);
            float _1441 = _1440 * _1436;
            _1443 = _1441;
          } else {
            _1443 = 0.0f;
          }
          float _1444 = _1443 + -1.0f;
          if (!_1268) {
            bool _1446 = (_1267 > 0.0f);
            bool _1447 = (_1267 < 0.0f);
            int _1448 = (int)(uint)(_1446);
            int _1449 = (int)(uint)(_1447);
            int _1450 = _1448 - _1449;
            float _1451 = float((int)(_1450));
            float _1452 = abs(_1267);
            float _1453 = log2(_1452);
            float _1454 = CustomPixelConsts_192.x * _1453;
            float _1455 = -0.0f - _1454;
            float _1456 = exp2(_1455);
            float _1457 = _1456 * _1451;
            _1459 = _1457;
          } else {
            _1459 = 0.0f;
          }
          float _1460 = _1459 * _1444;
          bool _1461 = (_1460 == 0.0f);
          if (!_1461) {
            bool _1463 = (_1460 > 0.0f);
            bool _1464 = (_1460 < 0.0f);
            int _1465 = (int)(uint)(_1463);
            int _1466 = (int)(uint)(_1464);
            int _1467 = _1465 - _1466;
            float _1468 = float((int)(_1467));
            float _1469 = abs(_1460);
            float _1470 = log2(_1469);
            float _1471 = _1470 * _1247;
            float _1472 = exp2(_1471);
            float _1473 = _1472 * _1468;
            _1475 = _1473;
          } else {
            _1475 = 0.0f;
          }
          float _1476 = _1241 - CustomPixelConsts_176.w;
          float _1477 = _1476 * CustomPixelConsts_176.x;
          float _1478 = _1477 / _1475;
          bool _1479 = (_1478 == 0.0f);
          if (!_1479) {
            bool _1481 = (_1478 > 0.0f);
            bool _1482 = (_1478 < 0.0f);
            int _1483 = (int)(uint)(_1481);
            int _1484 = (int)(uint)(_1482);
            int _1485 = _1483 - _1484;
            float _1486 = float((int)(_1485));
            float _1487 = abs(_1478);
            float _1488 = log2(_1487);
            float _1489 = _1488 * CustomPixelConsts_192.x;
            float _1490 = exp2(_1489);
            float _1491 = _1490 * _1486;
            _1493 = _1491;
          } else {
            _1493 = 0.0f;
          }
          float _1494 = _1493 + 1.0f;
          bool _1495 = (_1494 == 0.0f);
          if (!_1495) {
            bool _1497 = (_1494 > 0.0f);
            bool _1498 = (_1494 < 0.0f);
            int _1499 = (int)(uint)(_1497);
            int _1500 = (int)(uint)(_1498);
            int _1501 = _1499 - _1500;
            float _1502 = float((int)(_1501));
            float _1503 = abs(_1494);
            float _1504 = log2(_1503);
            float _1505 = _1504 * _1303;
            float _1506 = exp2(_1505);
            float _1507 = _1506 * _1502;
            _1509 = _1507;
          } else {
            _1509 = 0.0f;
          }
          float _1510 = _1478 / _1509;
          if (!_1339) {
            bool _1512 = (_1338 > 0.0f);
            bool _1513 = (_1338 < 0.0f);
            int _1514 = (int)(uint)(_1512);
            int _1515 = (int)(uint)(_1513);
            int _1516 = _1514 - _1515;
            float _1517 = float((int)(_1516));
            float _1518 = abs(_1338);
            float _1519 = log2(_1518);
            float _1520 = _1519 * CustomPixelConsts_176.y;
            float _1521 = exp2(_1520);
            float _1522 = _1521 * _1517;
            _1524 = _1522;
          } else {
            _1524 = 0.0f;
          }
          float _1525 = _1524 + -1.0f;
          if (!_1355) {
            bool _1527 = (_1337 > 0.0f);
            bool _1528 = (_1337 < 0.0f);
            int _1529 = (int)(uint)(_1527);
            int _1530 = (int)(uint)(_1528);
            int _1531 = _1529 - _1530;
            float _1532 = float((int)(_1531));
            float _1533 = abs(_1337);
            float _1534 = log2(_1533);
            float _1535 = CustomPixelConsts_176.y * _1534;
            float _1536 = -0.0f - _1535;
            float _1537 = exp2(_1536);
            float _1538 = _1537 * _1532;
            _1540 = _1538;
          } else {
            _1540 = 0.0f;
          }
          float _1541 = _1540 * _1525;
          bool _1542 = (_1541 == 0.0f);
          if (!_1542) {
            bool _1544 = (_1541 > 0.0f);
            bool _1545 = (_1541 < 0.0f);
            int _1546 = (int)(uint)(_1544);
            int _1547 = (int)(uint)(_1545);
            int _1548 = _1546 - _1547;
            float _1549 = float((int)(_1548));
            float _1550 = abs(_1541);
            float _1551 = log2(_1550);
            float _1552 = _1551 * _1336;
            float _1553 = exp2(_1552);
            float _1554 = _1553 * _1549;
            _1556 = _1554;
          } else {
            _1556 = 0.0f;
          }
          float _1557 = _1556 * _1387;
          float _1558 = -0.0f - _1557;
          float _1559 = _1477 / _1558;
          bool _1560 = (_1559 == 0.0f);
          if (!_1560) {
            bool _1562 = (_1559 > 0.0f);
            bool _1563 = (_1559 < 0.0f);
            int _1564 = (int)(uint)(_1562);
            int _1565 = (int)(uint)(_1563);
            int _1566 = _1564 - _1565;
            float _1567 = float((int)(_1566));
            float _1568 = abs(_1559);
            float _1569 = log2(_1568);
            float _1570 = _1569 * CustomPixelConsts_176.y;
            float _1571 = exp2(_1570);
            float _1572 = _1571 * _1567;
            _1574 = _1572;
          } else {
            _1574 = 0.0f;
          }
          float _1575 = _1574 + 1.0f;
          bool _1576 = (_1575 == 0.0f);
          if (!_1576) {
            bool _1578 = (_1575 > 0.0f);
            bool _1579 = (_1575 < 0.0f);
            int _1580 = (int)(uint)(_1578);
            int _1581 = (int)(uint)(_1579);
            int _1582 = _1580 - _1581;
            float _1583 = float((int)(_1582));
            float _1584 = abs(_1575);
            float _1585 = log2(_1584);
            float _1586 = _1585 * _1391;
            float _1587 = exp2(_1586);
            float _1588 = _1587 * _1583;
            _1590 = _1588;
          } else {
            _1590 = 0.0f;
          }
          float _1591 = _1559 / _1590;
          bool _1592 = (_1241 >= CustomPixelConsts_176.w);
          float _1593 = _1510 * _1475;
          float _1594 = _1557 * _1591;
          float _1595 = -0.0f - _1594;
          float _1596 = select(_1592, _1593, _1595);
          float _1597 = _1596 + 0.5f;
          if (!_1251) {
            bool _1599 = (_1250 > 0.0f);
            bool _1600 = (_1250 < 0.0f);
            int _1601 = (int)(uint)(_1599);
            int _1602 = (int)(uint)(_1600);
            int _1603 = _1601 - _1602;
            float _1604 = float((int)(_1603));
            float _1605 = abs(_1250);
            float _1606 = log2(_1605);
            float _1607 = _1606 * CustomPixelConsts_192.x;
            float _1608 = exp2(_1607);
            float _1609 = _1608 * _1604;
            _1611 = _1609;
          } else {
            _1611 = 0.0f;
          }
          float _1612 = _1611 + -1.0f;
          if (!_1268) {
            bool _1614 = (_1267 > 0.0f);
            bool _1615 = (_1267 < 0.0f);
            int _1616 = (int)(uint)(_1614);
            int _1617 = (int)(uint)(_1615);
            int _1618 = _1616 - _1617;
            float _1619 = float((int)(_1618));
            float _1620 = abs(_1267);
            float _1621 = log2(_1620);
            float _1622 = CustomPixelConsts_192.x * _1621;
            float _1623 = -0.0f - _1622;
            float _1624 = exp2(_1623);
            float _1625 = _1624 * _1619;
            _1627 = _1625;
          } else {
            _1627 = 0.0f;
          }
          float _1628 = _1627 * _1612;
          bool _1629 = (_1628 == 0.0f);
          if (!_1629) {
            bool _1631 = (_1628 > 0.0f);
            bool _1632 = (_1628 < 0.0f);
            int _1633 = (int)(uint)(_1631);
            int _1634 = (int)(uint)(_1632);
            int _1635 = _1633 - _1634;
            float _1636 = float((int)(_1635));
            float _1637 = abs(_1628);
            float _1638 = log2(_1637);
            float _1639 = _1638 * _1247;
            float _1640 = exp2(_1639);
            float _1641 = _1640 * _1636;
            _1643 = _1641;
          } else {
            _1643 = 0.0f;
          }
          float _1644 = _1242 - CustomPixelConsts_176.w;
          float _1645 = _1644 * CustomPixelConsts_176.x;
          float _1646 = _1645 / _1643;
          bool _1647 = (_1646 == 0.0f);
          if (!_1647) {
            bool _1649 = (_1646 > 0.0f);
            bool _1650 = (_1646 < 0.0f);
            int _1651 = (int)(uint)(_1649);
            int _1652 = (int)(uint)(_1650);
            int _1653 = _1651 - _1652;
            float _1654 = float((int)(_1653));
            float _1655 = abs(_1646);
            float _1656 = log2(_1655);
            float _1657 = _1656 * CustomPixelConsts_192.x;
            float _1658 = exp2(_1657);
            float _1659 = _1658 * _1654;
            _1661 = _1659;
          } else {
            _1661 = 0.0f;
          }
          float _1662 = _1661 + 1.0f;
          bool _1663 = (_1662 == 0.0f);
          if (!_1663) {
            bool _1665 = (_1662 > 0.0f);
            bool _1666 = (_1662 < 0.0f);
            int _1667 = (int)(uint)(_1665);
            int _1668 = (int)(uint)(_1666);
            int _1669 = _1667 - _1668;
            float _1670 = float((int)(_1669));
            float _1671 = abs(_1662);
            float _1672 = log2(_1671);
            float _1673 = _1672 * _1303;
            float _1674 = exp2(_1673);
            float _1675 = _1674 * _1670;
            _1677 = _1675;
          } else {
            _1677 = 0.0f;
          }
          float _1678 = _1646 / _1677;
          if (!_1339) {
            bool _1680 = (_1338 > 0.0f);
            bool _1681 = (_1338 < 0.0f);
            int _1682 = (int)(uint)(_1680);
            int _1683 = (int)(uint)(_1681);
            int _1684 = _1682 - _1683;
            float _1685 = float((int)(_1684));
            float _1686 = abs(_1338);
            float _1687 = log2(_1686);
            float _1688 = _1687 * CustomPixelConsts_176.y;
            float _1689 = exp2(_1688);
            float _1690 = _1689 * _1685;
            _1692 = _1690;
          } else {
            _1692 = 0.0f;
          }
          float _1693 = _1692 + -1.0f;
          if (!_1355) {
            bool _1695 = (_1337 > 0.0f);
            bool _1696 = (_1337 < 0.0f);
            int _1697 = (int)(uint)(_1695);
            int _1698 = (int)(uint)(_1696);
            int _1699 = _1697 - _1698;
            float _1700 = float((int)(_1699));
            float _1701 = abs(_1337);
            float _1702 = log2(_1701);
            float _1703 = CustomPixelConsts_176.y * _1702;
            float _1704 = -0.0f - _1703;
            float _1705 = exp2(_1704);
            float _1706 = _1705 * _1700;
            _1708 = _1706;
          } else {
            _1708 = 0.0f;
          }
          float _1709 = _1708 * _1693;
          bool _1710 = (_1709 == 0.0f);
          if (!_1710) {
            bool _1712 = (_1709 > 0.0f);
            bool _1713 = (_1709 < 0.0f);
            int _1714 = (int)(uint)(_1712);
            int _1715 = (int)(uint)(_1713);
            int _1716 = _1714 - _1715;
            float _1717 = float((int)(_1716));
            float _1718 = abs(_1709);
            float _1719 = log2(_1718);
            float _1720 = _1719 * _1336;
            float _1721 = exp2(_1720);
            float _1722 = _1721 * _1717;
            _1724 = _1722;
          } else {
            _1724 = 0.0f;
          }
          float _1725 = _1724 * _1387;
          float _1726 = -0.0f - _1725;
          float _1727 = _1645 / _1726;
          bool _1728 = (_1727 == 0.0f);
          if (!_1728) {
            bool _1730 = (_1727 > 0.0f);
            bool _1731 = (_1727 < 0.0f);
            int _1732 = (int)(uint)(_1730);
            int _1733 = (int)(uint)(_1731);
            int _1734 = _1732 - _1733;
            float _1735 = float((int)(_1734));
            float _1736 = abs(_1727);
            float _1737 = log2(_1736);
            float _1738 = _1737 * CustomPixelConsts_176.y;
            float _1739 = exp2(_1738);
            float _1740 = _1739 * _1735;
            _1742 = _1740;
          } else {
            _1742 = 0.0f;
          }
          float _1743 = _1742 + 1.0f;
          bool _1744 = (_1743 == 0.0f);
          if (!_1744) {
            bool _1746 = (_1743 > 0.0f);
            bool _1747 = (_1743 < 0.0f);
            int _1748 = (int)(uint)(_1746);
            int _1749 = (int)(uint)(_1747);
            int _1750 = _1748 - _1749;
            float _1751 = float((int)(_1750));
            float _1752 = abs(_1743);
            float _1753 = log2(_1752);
            float _1754 = _1753 * _1391;
            float _1755 = exp2(_1754);
            float _1756 = _1755 * _1751;
            _1758 = _1756;
          } else {
            _1758 = 0.0f;
          }
          float _1759 = _1727 / _1758;
          bool _1760 = (_1242 >= CustomPixelConsts_176.w);
          float _1761 = _1678 * _1643;
          float _1762 = _1725 * _1759;
          float _1763 = -0.0f - _1762;
          float _1764 = select(_1760, _1761, _1763);
          float _1765 = _1764 + 0.5f;
          _1813 = _1429;
          _1814 = _1597;
          _1815 = _1765;
        } else {
          float _1767 = _1240 * _1240;
          float _1768 = _1241 * _1241;
          float _1769 = _1242 * _1242;
          float _1770 = _1767 * _1767;
          float _1771 = _1768 * _1768;
          float _1772 = _1769 * _1769;
          float _1773 = _1767 * 15.5f;
          float _1774 = _1768 * 15.5f;
          float _1775 = _1769 * 15.5f;
          float _1776 = _1240 * -40.13999938964844f;
          float _1777 = _1241 * -40.13999938964844f;
          float _1778 = _1242 * -40.13999938964844f;
          float _1779 = _1240 * 6.868000030517578f;
          float _1780 = _1779 * _1767;
          float _1781 = _1241 * 6.868000030517578f;
          float _1782 = _1781 * _1768;
          float _1783 = _1242 * 6.868000030517578f;
          float _1784 = _1783 * _1769;
          float _1785 = _1767 * 0.42980000376701355f;
          float _1786 = _1768 * 0.42980000376701355f;
          float _1787 = _1769 * 0.42980000376701355f;
          float _1788 = _1240 * 0.11909999698400497f;
          float _1789 = _1241 * 0.11909999698400497f;
          float _1790 = _1242 * 0.11909999698400497f;
          float _1791 = _1773 + 31.959999084472656f;
          float _1792 = _1791 + _1776;
          float _1793 = _1770 * _1792;
          float _1794 = _1788 + -0.002319999970495701f;
          float _1795 = _1794 + _1785;
          float _1796 = _1795 - _1780;
          float _1797 = _1796 + _1793;
          float _1798 = _1774 + 31.959999084472656f;
          float _1799 = _1798 + _1777;
          float _1800 = _1771 * _1799;
          float _1801 = _1789 + -0.002319999970495701f;
          float _1802 = _1801 + _1786;
          float _1803 = _1802 - _1782;
          float _1804 = _1803 + _1800;
          float _1805 = _1775 + 31.959999084472656f;
          float _1806 = _1805 + _1778;
          float _1807 = _1772 * _1806;
          float _1808 = _1790 + -0.002319999970495701f;
          float _1809 = _1808 + _1787;
          float _1810 = _1809 - _1784;
          float _1811 = _1810 + _1807;
          _1813 = _1797;
          _1814 = _1804;
          _1815 = _1811;
        }
        float _1816 = _1813 * CustomPixelConsts_144.x;
        float _1817 = _1814 * CustomPixelConsts_144.y;
        float _1818 = _1815 * CustomPixelConsts_144.z;
        float _1819 = log2(_1816);
        float _1820 = log2(_1817);
        float _1821 = log2(_1818);
        float _1822 = _1819 * CustomPixelConsts_160.x;
        float _1823 = _1820 * CustomPixelConsts_160.y;
        float _1824 = _1821 * CustomPixelConsts_160.z;
        float _1825 = exp2(_1822);
        float _1826 = exp2(_1823);
        float _1827 = exp2(_1824);
        float _1828 = dot(float3(_1825, _1826, _1827), float3(0.2126729041337967f, 0.7151522040367126f, 0.07217500358819962f));
        float _1829 = _1825 - _1828;
        float _1830 = _1826 - _1828;
        float _1831 = _1827 - _1828;
        float _1832 = _1829 * CustomPixelConsts_144.w;
        float _1833 = _1830 * CustomPixelConsts_144.w;
        float _1834 = _1831 * CustomPixelConsts_144.w;
        float _1835 = _1832 + _1828;
        float _1836 = _1833 + _1828;
        float _1837 = _1834 + _1828;
        float _1838 = max(_1835, 0.0f);
        float _1839 = max(_1836, 0.0f);
        float _1840 = max(_1837, 0.0f);
        float _1841 = _1838 * 1.1968790292739868f;
        float _1842 = mad(_1839, -0.09802088141441345f, _1841);
        float _1843 = mad(_1840, -0.09902974218130112f, _1842);
        float _1844 = _1838 * -0.052896853536367416f;
        float _1845 = mad(_1839, 1.1519031524658203f, _1844);
        float _1846 = mad(_1840, -0.09896117448806763f, _1845);
        float _1847 = _1838 * -0.05297163501381874f;
        float _1848 = mad(_1839, -0.09804344922304153f, _1847);
        float _1849 = mad(_1840, 1.151073694229126f, _1848);
        float _1850 = max(_1843, 9.999999747378752e-05f);
        float _1851 = max(_1846, 9.999999747378752e-05f);
        float _1852 = max(_1849, 9.999999747378752e-05f);
        float _1853 = log2(_1850);
        float _1854 = log2(_1851);
        float _1855 = log2(_1852);
        float _1856 = _1853 * 2.200000047683716f;
        float _1857 = _1854 * 2.200000047683716f;
        float _1858 = _1855 * 2.200000047683716f;
        float _1859 = exp2(_1856);
        float _1860 = exp2(_1857);
        float _1861 = exp2(_1858);
        float _1862 = _1860 + _1859;
        float _1863 = _1862 + _1861;
        float _1864 = _1863 * 0.3333333432674408f;
        _1866 = _1864;
      } else {
        _1866 = 0.0f;
      }
    }
    float _1867 = _1866 * CustomPixelConsts_000.x;
    float _1868 = CustomPixelConsts_000.w / _1867;
    float _1869 = log2(CustomPixelConsts_128.z);
    float _1870 = _1869 * CustomPixelConsts_128.x;
    float _1871 = exp2(_1870);
    float _1872 = CustomPixelConsts_128.w - _1871;
    float _1873 = 1.0f - _1871;
    float _1874 = _1873 * CustomPixelConsts_128.w;
    float _1875 = _1872 / _1874;
    float _1876 = 1.0f - _1875;
    float _1877 = log2(_1183);
    float _1878 = _1877 * CustomPixelConsts_128.x;
    float _1879 = exp2(_1878);
    float _1880 = _1879 * _1875;
    float _1881 = _1876 + _1880;
    float _1882 = _1879 / _1881;
    float _1883 = _1868 + -1.0f;
    float _1884 = _1882 * _1883;
    float _1885 = _1884 + 1.0f;
    float _1886 = _1885 * _1144;
    float _1887 = _1885 * _1145;
    float _1888 = _1885 * _1146;
    _1890 = _1886;
    _1891 = _1887;
    _1892 = _1888;
  } else {
    _1890 = _1144;
    _1891 = _1145;
    _1892 = _1146;
  }
  bool _1893 = (_1101 == 0);
  if (!_1893) {
    float _1895 = _1174 - _1890;
    float _1896 = _1175 - _1891;
    float _1897 = _1176 - _1892;
    float _1898 = _78.w + -1.0f;
    float _1899 = _1895 * _78.w;
    float _1900 = _1896 * _78.w;
    float _1901 = _1897 * _78.w;
    float _1902 = _1898 * _78.w;
    float _1903 = _1899 + _1890;
    float _1904 = _1900 + _1891;
    float _1905 = _1901 + _1892;
    float _1906 = _1902 + 1.0f;
    _1908 = _1903;
    _1909 = _1904;
    _1910 = _1905;
    _1911 = _1906;
  } else {
    _1908 = _1890;
    _1909 = _1891;
    _1910 = _1892;
    _1911 = 1.0f;
  }
  // Primary presentation and scene-only FG output share white and peak.
  float output_white = WitcherUsePsychoV30() ? RENODX_DIFFUSE_WHITE_NITS : CustomPixelConsts_000.x;
  float output_peak = WitcherUsePsychoV30() ? RENODX_PEAK_WHITE_NITS : CustomPixelConsts_000.w;
  float _1912 = _1908 * output_white;
  float _1913 = _1909 * output_white;
  float _1914 = _1910 * output_white;
  float _1915 = min(WitcherUsePsychoV30() ? max(_1912, 0.f) : _1912, output_peak);
  float _1916 = min(WitcherUsePsychoV30() ? max(_1913, 0.f) : _1913, output_peak);
  float _1917 = min(WitcherUsePsychoV30() ? max(_1914, 0.f) : _1914, output_peak);
  float _1918 = _1915 * 9.999999747378752e-05f;
  float _1919 = _1916 * 9.999999747378752e-05f;
  float _1920 = _1917 * 9.999999747378752e-05f;
  float _1921 = log2(_1918);
  float _1922 = log2(_1919);
  float _1923 = log2(_1920);
  float _1924 = _1921 * 0.1593017578125f;
  float _1925 = _1922 * 0.1593017578125f;
  float _1926 = _1923 * 0.1593017578125f;
  float _1927 = exp2(_1924);
  float _1928 = exp2(_1925);
  float _1929 = exp2(_1926);
  float _1930 = _1927 * 18.8515625f;
  float _1931 = _1928 * 18.8515625f;
  float _1932 = _1929 * 18.8515625f;
  float _1933 = _1930 + 0.8359375f;
  float _1934 = _1931 + 0.8359375f;
  float _1935 = _1932 + 0.8359375f;
  float _1936 = _1927 * 18.6875f;
  float _1937 = _1928 * 18.6875f;
  float _1938 = _1929 * 18.6875f;
  float _1939 = _1936 + 1.0f;
  float _1940 = _1937 + 1.0f;
  float _1941 = _1938 + 1.0f;
  float _1942 = _1933 / _1939;
  float _1943 = _1934 / _1940;
  float _1944 = _1935 / _1941;
  float _1945 = log2(_1942);
  float _1946 = log2(_1943);
  float _1947 = log2(_1944);
  float _1948 = _1945 * 78.84375f;
  float _1949 = _1946 * 78.84375f;
  float _1950 = _1947 * 78.84375f;
  float _1951 = exp2(_1948);
  float _1952 = exp2(_1949);
  float _1953 = exp2(_1950);
  float _1954 = saturate(_1951);
  float _1955 = saturate(_1952);
  float _1956 = saturate(_1953);
  float _1957 = _302 * 0.627403974533081f;
  float _1958 = mad(0.3292819857597351f, _303, _1957);
  float _1959 = mad(0.04331360012292862f, _304, _1958);
  float _1960 = _302 * 0.06909699738025665f;
  float _1961 = mad(0.9195399880409241f, _303, _1960);
  float _1962 = mad(0.011361200362443924f, _304, _1961);
  float _1963 = _302 * 0.01639159955084324f;
  float _1964 = mad(0.08801320195198059f, _303, _1963);
  float _1965 = mad(0.8955950140953064f, _304, _1964);
  float _1966 = _1959 * CustomPixelConsts_064.x;
  float _1967 = mad(CustomPixelConsts_064.y, _1962, _1966);
  float _1968 = mad(CustomPixelConsts_064.z, _1965, _1967);
  float _1969 = _1959 * CustomPixelConsts_080.x;
  float _1970 = mad(CustomPixelConsts_080.y, _1962, _1969);
  float _1971 = mad(CustomPixelConsts_080.z, _1965, _1970);
  float _1972 = _1959 * CustomPixelConsts_096.x;
  float _1973 = mad(CustomPixelConsts_096.y, _1962, _1972);
  float _1974 = mad(CustomPixelConsts_096.z, _1965, _1973);
  float _1975 = WitcherUsePsychoV30() ? _1968 : saturate(_1968);
  float _1976 = WitcherUsePsychoV30() ? _1971 : saturate(_1971);
  float _1977 = WitcherUsePsychoV30() ? _1974 : saturate(_1974);
  float _1978 = _1975 - _1959;
  float _1979 = _1976 - _1962;
  float _1980 = _1977 - _1965;
  float _1981 = _1978 * native_hdr_saturation;
  float _1982 = _1979 * native_hdr_saturation;
  float _1983 = _1980 * native_hdr_saturation;
  float _1984 = _1981 + _1959;
  float _1985 = _1982 + _1962;
  float _1986 = _1983 + _1965;
  if (WitcherUsePsychoV30()) {
    // Native Target2 deliberately uses the undimmed, non-regional scene.
    // Preserve that contract; map it once without UI, with the same grain seed.
    float3 scene_only_bt2020 = WitcherToneMapOutput(float3(_1984, _1985, _1986), TEXCOORD);
    _1984 = scene_only_bt2020.x;
    _1985 = scene_only_bt2020.y;
    _1986 = scene_only_bt2020.z;
  }
  bool _1987 = (_85.w > CustomPixelConsts_032.w);
  bool _1988 = !WitcherUsePsychoV30() && _30 && _1987; // No native expansion in scene-only HDR either.
  if (_1988) {
    float _1990 = _85.w - CustomPixelConsts_032.w;
    float _1991 = CustomPixelConsts_112.z - CustomPixelConsts_032.w;
    float _1992 = _1990 / _1991;
    float _1993 = saturate(_1992);
    bool _1994 = (_34 == 0);
    if (_1994) {
      float _1996 = CustomPixelConsts_144.x * CustomPixelConsts_112.z;
      float _1997 = CustomPixelConsts_144.z * CustomPixelConsts_144.y;
      float _1998 = _1996 + _1997;
      float _1999 = _1998 * CustomPixelConsts_112.z;
      float _2000 = CustomPixelConsts_160.x * CustomPixelConsts_160.y;
      float _2001 = _1999 + _2000;
      float _2002 = _1996 + CustomPixelConsts_144.y;
      float _2003 = _2002 * CustomPixelConsts_112.z;
      float _2004 = CustomPixelConsts_160.x * CustomPixelConsts_160.z;
      float _2005 = _2003 + _2004;
      float _2006 = _2001 / _2005;
      float _2007 = CustomPixelConsts_160.y / CustomPixelConsts_160.z;
      float _2008 = _2006 - _2007;
      float _2009 = max(0.0f, _2008);
      float _2010 = CustomPixelConsts_144.x * 11.199999809265137f;
      float _2011 = _2010 + _1997;
      float _2012 = _2011 * 11.199999809265137f;
      float _2013 = _2012 + _2000;
      float _2014 = _2010 + CustomPixelConsts_144.y;
      float _2015 = _2014 * 11.199999809265137f;
      float _2016 = _2015 + _2004;
      float _2017 = _2013 / _2016;
      float _2018 = _2017 - _2007;
      float _2019 = max(0.0f, _2018);
      float _2020 = _2009 / _2019;
      _2676 = _2020;
    } else {
      bool _2022 = (_34 == 1);
      if (_2022) {
        float _2024 = CustomPixelConsts_160.w * 0.0009765625f;
        float _2025 = log2(_2024);
        float _2026 = CustomPixelConsts_160.w * 90.5096664428711f;
        float _2027 = log2(_2026);
        float _2028 = CustomPixelConsts_112.z * 0.8424790501594543f;
        float _2029 = mad(CustomPixelConsts_112.z, 0.07843360304832458f, _2028);
        float _2030 = mad(CustomPixelConsts_112.z, 0.07922374457120895f, _2029);
        float _2031 = CustomPixelConsts_112.z * 0.04232824221253395f;
        float _2032 = mad(CustomPixelConsts_112.z, 0.8784686326980591f, _2031);
        float _2033 = mad(CustomPixelConsts_112.z, 0.07916612923145294f, _2032);
        float _2034 = CustomPixelConsts_112.z * 0.042375653982162476f;
        float _2035 = mad(CustomPixelConsts_112.z, 0.07843360304832458f, _2034);
        float _2036 = mad(CustomPixelConsts_112.z, 0.8791429996490479f, _2035);
        float _2037 = log2(_2030);
        float _2038 = log2(_2033);
        float _2039 = log2(_2036);
        float _2040 = max(_2037, _2025);
        float _2041 = max(_2038, _2025);
        float _2042 = max(_2039, _2025);
        float _2043 = min(_2040, _2027);
        float _2044 = min(_2041, _2027);
        float _2045 = min(_2042, _2027);
        float _2046 = _2043 - _2025;
        float _2047 = _2044 - _2025;
        float _2048 = _2045 - _2025;
        float _2049 = _2027 - _2025;
        float _2050 = _2046 / _2049;
        float _2051 = _2047 / _2049;
        float _2052 = _2048 / _2049;
        bool _2055 = (cb12_221w > 0.0f);
        [branch]
        if (_2055) {
          float _2057 = -1.0f / CustomPixelConsts_192.x;
          float _2058 = 1.0f - CustomPixelConsts_176.w;
          float _2059 = CustomPixelConsts_176.x * 2.0f;
          float _2060 = _2059 * _2058;
          bool _2061 = (_2060 == 0.0f);
          if (!_2061) {
            bool _2063 = (_2060 > 0.0f);
            bool _2064 = (_2060 < 0.0f);
            int _2065 = (int)(uint)(_2063);
            int _2066 = (int)(uint)(_2064);
            int _2067 = _2065 - _2066;
            float _2068 = float((int)(_2067));
            float _2069 = abs(_2060);
            float _2070 = log2(_2069);
            float _2071 = _2070 * CustomPixelConsts_192.x;
            float _2072 = exp2(_2071);
            float _2073 = _2072 * _2068;
            _2075 = _2073;
          } else {
            _2075 = 0.0f;
          }
          float _2076 = _2075 + -1.0f;
          float _2077 = _2058 * CustomPixelConsts_176.x;
          bool _2078 = (_2077 == 0.0f);
          if (!_2078) {
            bool _2080 = (_2077 > 0.0f);
            bool _2081 = (_2077 < 0.0f);
            int _2082 = (int)(uint)(_2080);
            int _2083 = (int)(uint)(_2081);
            int _2084 = _2082 - _2083;
            float _2085 = float((int)(_2084));
            float _2086 = abs(_2077);
            float _2087 = log2(_2086);
            float _2088 = CustomPixelConsts_192.x * _2087;
            float _2089 = -0.0f - _2088;
            float _2090 = exp2(_2089);
            float _2091 = _2090 * _2085;
            _2093 = _2091;
          } else {
            _2093 = 0.0f;
          }
          float _2094 = _2093 * _2076;
          bool _2095 = (_2094 == 0.0f);
          if (!_2095) {
            bool _2097 = (_2094 > 0.0f);
            bool _2098 = (_2094 < 0.0f);
            int _2099 = (int)(uint)(_2097);
            int _2100 = (int)(uint)(_2098);
            int _2101 = _2099 - _2100;
            float _2102 = float((int)(_2101));
            float _2103 = abs(_2094);
            float _2104 = log2(_2103);
            float _2105 = _2104 * _2057;
            float _2106 = exp2(_2105);
            float _2107 = _2106 * _2102;
            _2109 = _2107;
          } else {
            _2109 = 0.0f;
          }
          float _2110 = _2050 - CustomPixelConsts_176.w;
          float _2111 = _2110 * CustomPixelConsts_176.x;
          float _2112 = _2111 / _2109;
          float _2113 = 1.0f / CustomPixelConsts_192.x;
          bool _2114 = (_2112 == 0.0f);
          if (!_2114) {
            bool _2116 = (_2112 > 0.0f);
            bool _2117 = (_2112 < 0.0f);
            int _2118 = (int)(uint)(_2116);
            int _2119 = (int)(uint)(_2117);
            int _2120 = _2118 - _2119;
            float _2121 = float((int)(_2120));
            float _2122 = abs(_2112);
            float _2123 = log2(_2122);
            float _2124 = _2123 * CustomPixelConsts_192.x;
            float _2125 = exp2(_2124);
            float _2126 = _2125 * _2121;
            _2128 = _2126;
          } else {
            _2128 = 0.0f;
          }
          float _2129 = _2128 + 1.0f;
          bool _2130 = (_2129 == 0.0f);
          if (!_2130) {
            bool _2132 = (_2129 > 0.0f);
            bool _2133 = (_2129 < 0.0f);
            int _2134 = (int)(uint)(_2132);
            int _2135 = (int)(uint)(_2133);
            int _2136 = _2134 - _2135;
            float _2137 = float((int)(_2136));
            float _2138 = abs(_2129);
            float _2139 = log2(_2138);
            float _2140 = _2139 * _2113;
            float _2141 = exp2(_2140);
            float _2142 = _2141 * _2137;
            _2144 = _2142;
          } else {
            _2144 = 0.0f;
          }
          float _2145 = _2112 / _2144;
          float _2146 = -1.0f / CustomPixelConsts_176.y;
          float _2147 = CustomPixelConsts_176.x * CustomPixelConsts_176.w;
          float _2148 = _2147 * 2.0f;
          bool _2149 = (_2148 == 0.0f);
          if (!_2149) {
            bool _2151 = (_2148 > 0.0f);
            bool _2152 = (_2148 < 0.0f);
            int _2153 = (int)(uint)(_2151);
            int _2154 = (int)(uint)(_2152);
            int _2155 = _2153 - _2154;
            float _2156 = float((int)(_2155));
            float _2157 = abs(_2148);
            float _2158 = log2(_2157);
            float _2159 = _2158 * CustomPixelConsts_176.y;
            float _2160 = exp2(_2159);
            float _2161 = _2160 * _2156;
            _2163 = _2161;
          } else {
            _2163 = 0.0f;
          }
          float _2164 = _2163 + -1.0f;
          bool _2165 = (_2147 == 0.0f);
          if (!_2165) {
            bool _2167 = (_2147 > 0.0f);
            bool _2168 = (_2147 < 0.0f);
            int _2169 = (int)(uint)(_2167);
            int _2170 = (int)(uint)(_2168);
            int _2171 = _2169 - _2170;
            float _2172 = float((int)(_2171));
            float _2173 = abs(_2147);
            float _2174 = log2(_2173);
            float _2175 = CustomPixelConsts_176.y * _2174;
            float _2176 = -0.0f - _2175;
            float _2177 = exp2(_2176);
            float _2178 = _2177 * _2172;
            _2180 = _2178;
          } else {
            _2180 = 0.0f;
          }
          float _2181 = _2180 * _2164;
          bool _2182 = (_2181 == 0.0f);
          if (!_2182) {
            bool _2184 = (_2181 > 0.0f);
            bool _2185 = (_2181 < 0.0f);
            int _2186 = (int)(uint)(_2184);
            int _2187 = (int)(uint)(_2185);
            int _2188 = _2186 - _2187;
            float _2189 = float((int)(_2188));
            float _2190 = abs(_2181);
            float _2191 = log2(_2190);
            float _2192 = _2191 * _2146;
            float _2193 = exp2(_2192);
            float _2194 = _2193 * _2189;
            _2196 = _2194;
          } else {
            _2196 = 0.0f;
          }
          float _2197 = 1.0f - CustomPixelConsts_176.z;
          float _2198 = _2196 * _2197;
          float _2199 = -0.0f - _2198;
          float _2200 = _2111 / _2199;
          float _2201 = 1.0f / CustomPixelConsts_176.y;
          bool _2202 = (_2200 == 0.0f);
          if (!_2202) {
            bool _2204 = (_2200 > 0.0f);
            bool _2205 = (_2200 < 0.0f);
            int _2206 = (int)(uint)(_2204);
            int _2207 = (int)(uint)(_2205);
            int _2208 = _2206 - _2207;
            float _2209 = float((int)(_2208));
            float _2210 = abs(_2200);
            float _2211 = log2(_2210);
            float _2212 = _2211 * CustomPixelConsts_176.y;
            float _2213 = exp2(_2212);
            float _2214 = _2213 * _2209;
            _2216 = _2214;
          } else {
            _2216 = 0.0f;
          }
          float _2217 = _2216 + 1.0f;
          bool _2218 = (_2217 == 0.0f);
          if (!_2218) {
            bool _2220 = (_2217 > 0.0f);
            bool _2221 = (_2217 < 0.0f);
            int _2222 = (int)(uint)(_2220);
            int _2223 = (int)(uint)(_2221);
            int _2224 = _2222 - _2223;
            float _2225 = float((int)(_2224));
            float _2226 = abs(_2217);
            float _2227 = log2(_2226);
            float _2228 = _2227 * _2201;
            float _2229 = exp2(_2228);
            float _2230 = _2229 * _2225;
            _2232 = _2230;
          } else {
            _2232 = 0.0f;
          }
          float _2233 = _2200 / _2232;
          bool _2234 = (_2050 >= CustomPixelConsts_176.w);
          float _2235 = _2145 * _2109;
          float _2236 = _2198 * _2233;
          float _2237 = -0.0f - _2236;
          float _2238 = select(_2234, _2235, _2237);
          float _2239 = _2238 + 0.5f;
          if (!_2061) {
            bool _2241 = (_2060 > 0.0f);
            bool _2242 = (_2060 < 0.0f);
            int _2243 = (int)(uint)(_2241);
            int _2244 = (int)(uint)(_2242);
            int _2245 = _2243 - _2244;
            float _2246 = float((int)(_2245));
            float _2247 = abs(_2060);
            float _2248 = log2(_2247);
            float _2249 = _2248 * CustomPixelConsts_192.x;
            float _2250 = exp2(_2249);
            float _2251 = _2250 * _2246;
            _2253 = _2251;
          } else {
            _2253 = 0.0f;
          }
          float _2254 = _2253 + -1.0f;
          if (!_2078) {
            bool _2256 = (_2077 > 0.0f);
            bool _2257 = (_2077 < 0.0f);
            int _2258 = (int)(uint)(_2256);
            int _2259 = (int)(uint)(_2257);
            int _2260 = _2258 - _2259;
            float _2261 = float((int)(_2260));
            float _2262 = abs(_2077);
            float _2263 = log2(_2262);
            float _2264 = CustomPixelConsts_192.x * _2263;
            float _2265 = -0.0f - _2264;
            float _2266 = exp2(_2265);
            float _2267 = _2266 * _2261;
            _2269 = _2267;
          } else {
            _2269 = 0.0f;
          }
          float _2270 = _2269 * _2254;
          bool _2271 = (_2270 == 0.0f);
          if (!_2271) {
            bool _2273 = (_2270 > 0.0f);
            bool _2274 = (_2270 < 0.0f);
            int _2275 = (int)(uint)(_2273);
            int _2276 = (int)(uint)(_2274);
            int _2277 = _2275 - _2276;
            float _2278 = float((int)(_2277));
            float _2279 = abs(_2270);
            float _2280 = log2(_2279);
            float _2281 = _2280 * _2057;
            float _2282 = exp2(_2281);
            float _2283 = _2282 * _2278;
            _2285 = _2283;
          } else {
            _2285 = 0.0f;
          }
          float _2286 = _2051 - CustomPixelConsts_176.w;
          float _2287 = _2286 * CustomPixelConsts_176.x;
          float _2288 = _2287 / _2285;
          bool _2289 = (_2288 == 0.0f);
          if (!_2289) {
            bool _2291 = (_2288 > 0.0f);
            bool _2292 = (_2288 < 0.0f);
            int _2293 = (int)(uint)(_2291);
            int _2294 = (int)(uint)(_2292);
            int _2295 = _2293 - _2294;
            float _2296 = float((int)(_2295));
            float _2297 = abs(_2288);
            float _2298 = log2(_2297);
            float _2299 = _2298 * CustomPixelConsts_192.x;
            float _2300 = exp2(_2299);
            float _2301 = _2300 * _2296;
            _2303 = _2301;
          } else {
            _2303 = 0.0f;
          }
          float _2304 = _2303 + 1.0f;
          bool _2305 = (_2304 == 0.0f);
          if (!_2305) {
            bool _2307 = (_2304 > 0.0f);
            bool _2308 = (_2304 < 0.0f);
            int _2309 = (int)(uint)(_2307);
            int _2310 = (int)(uint)(_2308);
            int _2311 = _2309 - _2310;
            float _2312 = float((int)(_2311));
            float _2313 = abs(_2304);
            float _2314 = log2(_2313);
            float _2315 = _2314 * _2113;
            float _2316 = exp2(_2315);
            float _2317 = _2316 * _2312;
            _2319 = _2317;
          } else {
            _2319 = 0.0f;
          }
          float _2320 = _2288 / _2319;
          if (!_2149) {
            bool _2322 = (_2148 > 0.0f);
            bool _2323 = (_2148 < 0.0f);
            int _2324 = (int)(uint)(_2322);
            int _2325 = (int)(uint)(_2323);
            int _2326 = _2324 - _2325;
            float _2327 = float((int)(_2326));
            float _2328 = abs(_2148);
            float _2329 = log2(_2328);
            float _2330 = _2329 * CustomPixelConsts_176.y;
            float _2331 = exp2(_2330);
            float _2332 = _2331 * _2327;
            _2334 = _2332;
          } else {
            _2334 = 0.0f;
          }
          float _2335 = _2334 + -1.0f;
          if (!_2165) {
            bool _2337 = (_2147 > 0.0f);
            bool _2338 = (_2147 < 0.0f);
            int _2339 = (int)(uint)(_2337);
            int _2340 = (int)(uint)(_2338);
            int _2341 = _2339 - _2340;
            float _2342 = float((int)(_2341));
            float _2343 = abs(_2147);
            float _2344 = log2(_2343);
            float _2345 = CustomPixelConsts_176.y * _2344;
            float _2346 = -0.0f - _2345;
            float _2347 = exp2(_2346);
            float _2348 = _2347 * _2342;
            _2350 = _2348;
          } else {
            _2350 = 0.0f;
          }
          float _2351 = _2350 * _2335;
          bool _2352 = (_2351 == 0.0f);
          if (!_2352) {
            bool _2354 = (_2351 > 0.0f);
            bool _2355 = (_2351 < 0.0f);
            int _2356 = (int)(uint)(_2354);
            int _2357 = (int)(uint)(_2355);
            int _2358 = _2356 - _2357;
            float _2359 = float((int)(_2358));
            float _2360 = abs(_2351);
            float _2361 = log2(_2360);
            float _2362 = _2361 * _2146;
            float _2363 = exp2(_2362);
            float _2364 = _2363 * _2359;
            _2366 = _2364;
          } else {
            _2366 = 0.0f;
          }
          float _2367 = _2366 * _2197;
          float _2368 = -0.0f - _2367;
          float _2369 = _2287 / _2368;
          bool _2370 = (_2369 == 0.0f);
          if (!_2370) {
            bool _2372 = (_2369 > 0.0f);
            bool _2373 = (_2369 < 0.0f);
            int _2374 = (int)(uint)(_2372);
            int _2375 = (int)(uint)(_2373);
            int _2376 = _2374 - _2375;
            float _2377 = float((int)(_2376));
            float _2378 = abs(_2369);
            float _2379 = log2(_2378);
            float _2380 = _2379 * CustomPixelConsts_176.y;
            float _2381 = exp2(_2380);
            float _2382 = _2381 * _2377;
            float _2383 = _2382 + 1.0f;
            _2385 = _2383;
          } else {
            _2385 = 1.0f;
          }
          bool _2386 = (_2385 == 0.0f);
          if (!_2386) {
            bool _2388 = (_2385 > 0.0f);
            bool _2389 = (_2385 < 0.0f);
            int _2390 = (int)(uint)(_2388);
            int _2391 = (int)(uint)(_2389);
            int _2392 = _2390 - _2391;
            float _2393 = float((int)(_2392));
            float _2394 = abs(_2385);
            float _2395 = log2(_2394);
            float _2396 = _2395 * _2201;
            float _2397 = exp2(_2396);
            float _2398 = _2397 * _2393;
            _2400 = _2398;
          } else {
            _2400 = 0.0f;
          }
          float _2401 = _2369 / _2400;
          bool _2402 = (_2051 >= CustomPixelConsts_176.w);
          float _2403 = _2320 * _2285;
          float _2404 = _2367 * _2401;
          float _2405 = -0.0f - _2404;
          float _2406 = select(_2402, _2403, _2405);
          float _2407 = _2406 + 0.5f;
          if (!_2061) {
            bool _2409 = (_2060 > 0.0f);
            bool _2410 = (_2060 < 0.0f);
            int _2411 = (int)(uint)(_2409);
            int _2412 = (int)(uint)(_2410);
            int _2413 = _2411 - _2412;
            float _2414 = float((int)(_2413));
            float _2415 = abs(_2060);
            float _2416 = log2(_2415);
            float _2417 = _2416 * CustomPixelConsts_192.x;
            float _2418 = exp2(_2417);
            float _2419 = _2418 * _2414;
            float _2420 = _2419 + -1.0f;
            _2422 = _2420;
          } else {
            _2422 = -1.0f;
          }
          if (!_2078) {
            bool _2424 = (_2077 > 0.0f);
            bool _2425 = (_2077 < 0.0f);
            int _2426 = (int)(uint)(_2424);
            int _2427 = (int)(uint)(_2425);
            int _2428 = _2426 - _2427;
            float _2429 = float((int)(_2428));
            float _2430 = abs(_2077);
            float _2431 = log2(_2430);
            float _2432 = CustomPixelConsts_192.x * _2431;
            float _2433 = -0.0f - _2432;
            float _2434 = exp2(_2433);
            float _2435 = _2434 * _2429;
            _2437 = _2435;
          } else {
            _2437 = 0.0f;
          }
          float _2438 = _2437 * _2422;
          bool _2439 = (_2438 == 0.0f);
          if (!_2439) {
            bool _2441 = (_2438 > 0.0f);
            bool _2442 = (_2438 < 0.0f);
            int _2443 = (int)(uint)(_2441);
            int _2444 = (int)(uint)(_2442);
            int _2445 = _2443 - _2444;
            float _2446 = float((int)(_2445));
            float _2447 = abs(_2438);
            float _2448 = log2(_2447);
            float _2449 = _2448 * _2057;
            float _2450 = exp2(_2449);
            float _2451 = _2450 * _2446;
            _2453 = _2451;
          } else {
            _2453 = 0.0f;
          }
          float _2454 = _2052 - CustomPixelConsts_176.w;
          float _2455 = _2454 * CustomPixelConsts_176.x;
          float _2456 = _2455 / _2453;
          bool _2457 = (_2456 == 0.0f);
          if (!_2457) {
            bool _2459 = (_2456 > 0.0f);
            bool _2460 = (_2456 < 0.0f);
            int _2461 = (int)(uint)(_2459);
            int _2462 = (int)(uint)(_2460);
            int _2463 = _2461 - _2462;
            float _2464 = float((int)(_2463));
            float _2465 = abs(_2456);
            float _2466 = log2(_2465);
            float _2467 = _2466 * CustomPixelConsts_192.x;
            float _2468 = exp2(_2467);
            float _2469 = _2468 * _2464;
            float _2470 = _2469 + 1.0f;
            _2472 = _2470;
          } else {
            _2472 = 1.0f;
          }
          bool _2473 = (_2472 == 0.0f);
          if (!_2473) {
            bool _2475 = (_2472 > 0.0f);
            bool _2476 = (_2472 < 0.0f);
            int _2477 = (int)(uint)(_2475);
            int _2478 = (int)(uint)(_2476);
            int _2479 = _2477 - _2478;
            float _2480 = float((int)(_2479));
            float _2481 = abs(_2472);
            float _2482 = log2(_2481);
            float _2483 = _2482 * _2113;
            float _2484 = exp2(_2483);
            float _2485 = _2484 * _2480;
            _2487 = _2485;
          } else {
            _2487 = 0.0f;
          }
          float _2488 = _2456 / _2487;
          if (!_2149) {
            bool _2490 = (_2148 > 0.0f);
            bool _2491 = (_2148 < 0.0f);
            int _2492 = (int)(uint)(_2490);
            int _2493 = (int)(uint)(_2491);
            int _2494 = _2492 - _2493;
            float _2495 = float((int)(_2494));
            float _2496 = abs(_2148);
            float _2497 = log2(_2496);
            float _2498 = _2497 * CustomPixelConsts_176.y;
            float _2499 = exp2(_2498);
            float _2500 = _2499 * _2495;
            float _2501 = _2500 + -1.0f;
            _2503 = _2501;
          } else {
            _2503 = -1.0f;
          }
          if (!_2165) {
            bool _2505 = (_2147 > 0.0f);
            bool _2506 = (_2147 < 0.0f);
            int _2507 = (int)(uint)(_2505);
            int _2508 = (int)(uint)(_2506);
            int _2509 = _2507 - _2508;
            float _2510 = float((int)(_2509));
            float _2511 = abs(_2147);
            float _2512 = log2(_2511);
            float _2513 = CustomPixelConsts_176.y * _2512;
            float _2514 = -0.0f - _2513;
            float _2515 = exp2(_2514);
            float _2516 = _2515 * _2510;
            _2518 = _2516;
          } else {
            _2518 = 0.0f;
          }
          float _2519 = _2518 * _2503;
          bool _2520 = (_2519 == 0.0f);
          if (!_2520) {
            bool _2522 = (_2519 > 0.0f);
            bool _2523 = (_2519 < 0.0f);
            int _2524 = (int)(uint)(_2522);
            int _2525 = (int)(uint)(_2523);
            int _2526 = _2524 - _2525;
            float _2527 = float((int)(_2526));
            float _2528 = abs(_2519);
            float _2529 = log2(_2528);
            float _2530 = _2529 * _2146;
            float _2531 = exp2(_2530);
            float _2532 = _2531 * _2527;
            _2534 = _2532;
          } else {
            _2534 = 0.0f;
          }
          float _2535 = _2534 * _2197;
          float _2536 = -0.0f - _2535;
          float _2537 = _2455 / _2536;
          bool _2538 = (_2537 == 0.0f);
          if (!_2538) {
            bool _2540 = (_2537 > 0.0f);
            bool _2541 = (_2537 < 0.0f);
            int _2542 = (int)(uint)(_2540);
            int _2543 = (int)(uint)(_2541);
            int _2544 = _2542 - _2543;
            float _2545 = float((int)(_2544));
            float _2546 = abs(_2537);
            float _2547 = log2(_2546);
            float _2548 = _2547 * CustomPixelConsts_176.y;
            float _2549 = exp2(_2548);
            float _2550 = _2549 * _2545;
            float _2551 = _2550 + 1.0f;
            _2553 = _2551;
          } else {
            _2553 = 1.0f;
          }
          bool _2554 = (_2553 == 0.0f);
          if (!_2554) {
            bool _2556 = (_2553 > 0.0f);
            bool _2557 = (_2553 < 0.0f);
            int _2558 = (int)(uint)(_2556);
            int _2559 = (int)(uint)(_2557);
            int _2560 = _2558 - _2559;
            float _2561 = float((int)(_2560));
            float _2562 = abs(_2553);
            float _2563 = log2(_2562);
            float _2564 = _2563 * _2201;
            float _2565 = exp2(_2564);
            float _2566 = _2565 * _2561;
            _2568 = _2566;
          } else {
            _2568 = 0.0f;
          }
          float _2569 = _2537 / _2568;
          bool _2570 = (_2052 >= CustomPixelConsts_176.w);
          float _2571 = _2488 * _2453;
          float _2572 = _2535 * _2569;
          float _2573 = -0.0f - _2572;
          float _2574 = select(_2570, _2571, _2573);
          float _2575 = _2574 + 0.5f;
          _2623 = _2239;
          _2624 = _2407;
          _2625 = _2575;
        } else {
          float _2577 = _2050 * _2050;
          float _2578 = _2051 * _2051;
          float _2579 = _2052 * _2052;
          float _2580 = _2577 * _2577;
          float _2581 = _2578 * _2578;
          float _2582 = _2579 * _2579;
          float _2583 = _2577 * 15.5f;
          float _2584 = _2578 * 15.5f;
          float _2585 = _2579 * 15.5f;
          float _2586 = _2050 * -40.13999938964844f;
          float _2587 = _2051 * -40.13999938964844f;
          float _2588 = _2052 * -40.13999938964844f;
          float _2589 = _2050 * 6.868000030517578f;
          float _2590 = _2589 * _2577;
          float _2591 = _2051 * 6.868000030517578f;
          float _2592 = _2591 * _2578;
          float _2593 = _2052 * 6.868000030517578f;
          float _2594 = _2593 * _2579;
          float _2595 = _2577 * 0.42980000376701355f;
          float _2596 = _2578 * 0.42980000376701355f;
          float _2597 = _2579 * 0.42980000376701355f;
          float _2598 = _2050 * 0.11909999698400497f;
          float _2599 = _2051 * 0.11909999698400497f;
          float _2600 = _2052 * 0.11909999698400497f;
          float _2601 = _2583 + 31.959999084472656f;
          float _2602 = _2601 + _2586;
          float _2603 = _2580 * _2602;
          float _2604 = _2598 + -0.002319999970495701f;
          float _2605 = _2604 + _2595;
          float _2606 = _2605 - _2590;
          float _2607 = _2606 + _2603;
          float _2608 = _2584 + 31.959999084472656f;
          float _2609 = _2608 + _2587;
          float _2610 = _2581 * _2609;
          float _2611 = _2599 + -0.002319999970495701f;
          float _2612 = _2611 + _2596;
          float _2613 = _2612 - _2592;
          float _2614 = _2613 + _2610;
          float _2615 = _2585 + 31.959999084472656f;
          float _2616 = _2615 + _2588;
          float _2617 = _2582 * _2616;
          float _2618 = _2600 + -0.002319999970495701f;
          float _2619 = _2618 + _2597;
          float _2620 = _2619 - _2594;
          float _2621 = _2620 + _2617;
          _2623 = _2607;
          _2624 = _2614;
          _2625 = _2621;
        }
        float _2626 = _2623 * CustomPixelConsts_144.x;
        float _2627 = _2624 * CustomPixelConsts_144.y;
        float _2628 = _2625 * CustomPixelConsts_144.z;
        float _2629 = log2(_2626);
        float _2630 = log2(_2627);
        float _2631 = log2(_2628);
        float _2632 = _2629 * CustomPixelConsts_160.x;
        float _2633 = _2630 * CustomPixelConsts_160.y;
        float _2634 = _2631 * CustomPixelConsts_160.z;
        float _2635 = exp2(_2632);
        float _2636 = exp2(_2633);
        float _2637 = exp2(_2634);
        float _2638 = dot(float3(_2635, _2636, _2637), float3(0.2126729041337967f, 0.7151522040367126f, 0.07217500358819962f));
        float _2639 = _2635 - _2638;
        float _2640 = _2636 - _2638;
        float _2641 = _2637 - _2638;
        float _2642 = _2639 * CustomPixelConsts_144.w;
        float _2643 = _2640 * CustomPixelConsts_144.w;
        float _2644 = _2641 * CustomPixelConsts_144.w;
        float _2645 = _2642 + _2638;
        float _2646 = _2643 + _2638;
        float _2647 = _2644 + _2638;
        float _2648 = max(_2645, 0.0f);
        float _2649 = max(_2646, 0.0f);
        float _2650 = max(_2647, 0.0f);
        float _2651 = _2648 * 1.1968790292739868f;
        float _2652 = mad(_2649, -0.09802088141441345f, _2651);
        float _2653 = mad(_2650, -0.09902974218130112f, _2652);
        float _2654 = _2648 * -0.052896853536367416f;
        float _2655 = mad(_2649, 1.1519031524658203f, _2654);
        float _2656 = mad(_2650, -0.09896117448806763f, _2655);
        float _2657 = _2648 * -0.05297163501381874f;
        float _2658 = mad(_2649, -0.09804344922304153f, _2657);
        float _2659 = mad(_2650, 1.151073694229126f, _2658);
        float _2660 = max(_2653, 9.999999747378752e-05f);
        float _2661 = max(_2656, 9.999999747378752e-05f);
        float _2662 = max(_2659, 9.999999747378752e-05f);
        float _2663 = log2(_2660);
        float _2664 = log2(_2661);
        float _2665 = log2(_2662);
        float _2666 = _2663 * 2.200000047683716f;
        float _2667 = _2664 * 2.200000047683716f;
        float _2668 = _2665 * 2.200000047683716f;
        float _2669 = exp2(_2666);
        float _2670 = exp2(_2667);
        float _2671 = exp2(_2668);
        float _2672 = _2670 + _2669;
        float _2673 = _2672 + _2671;
        float _2674 = _2673 * 0.3333333432674408f;
        _2676 = _2674;
      } else {
        _2676 = 0.0f;
      }
    }
    float _2677 = _2676 * CustomPixelConsts_000.x;
    float _2678 = CustomPixelConsts_000.w / _2677;
    float _2679 = log2(CustomPixelConsts_128.z);
    float _2680 = _2679 * CustomPixelConsts_128.x;
    float _2681 = exp2(_2680);
    float _2682 = CustomPixelConsts_128.w - _2681;
    float _2683 = 1.0f - _2681;
    float _2684 = _2683 * CustomPixelConsts_128.w;
    float _2685 = _2682 / _2684;
    float _2686 = 1.0f - _2685;
    float _2687 = log2(_1993);
    float _2688 = _2687 * CustomPixelConsts_128.x;
    float _2689 = exp2(_2688);
    float _2690 = _2689 * _2685;
    float _2691 = _2686 + _2690;
    float _2692 = _2689 / _2691;
    float _2693 = _2678 + -1.0f;
    float _2694 = _2692 * _2693;
    float _2695 = _2694 + 1.0f;
    float _2696 = _2695 * _1984;
    float _2697 = _2695 * _1985;
    float _2698 = _2695 * _1986;
    _2700 = _2696;
    _2701 = _2697;
    _2702 = _2698;
  } else {
    _2700 = _1984;
    _2701 = _1985;
    _2702 = _1986;
  }
  float _2703 = _2700 * output_white;
  float _2704 = _2701 * output_white;
  float _2705 = _2702 * output_white;
  float _2706 = min(WitcherUsePsychoV30() ? max(_2703, 0.f) : _2703, output_peak);
  float _2707 = min(WitcherUsePsychoV30() ? max(_2704, 0.f) : _2704, output_peak);
  float _2708 = min(WitcherUsePsychoV30() ? max(_2705, 0.f) : _2705, output_peak);
  float _2709 = _2706 * 9.999999747378752e-05f;
  float _2710 = _2707 * 9.999999747378752e-05f;
  float _2711 = _2708 * 9.999999747378752e-05f;
  float _2712 = log2(_2709);
  float _2713 = log2(_2710);
  float _2714 = log2(_2711);
  float _2715 = _2712 * 0.1593017578125f;
  float _2716 = _2713 * 0.1593017578125f;
  float _2717 = _2714 * 0.1593017578125f;
  float _2718 = exp2(_2715);
  float _2719 = exp2(_2716);
  float _2720 = exp2(_2717);
  float _2721 = _2718 * 18.8515625f;
  float _2722 = _2719 * 18.8515625f;
  float _2723 = _2720 * 18.8515625f;
  float _2724 = _2721 + 0.8359375f;
  float _2725 = _2722 + 0.8359375f;
  float _2726 = _2723 + 0.8359375f;
  float _2727 = _2718 * 18.6875f;
  float _2728 = _2719 * 18.6875f;
  float _2729 = _2720 * 18.6875f;
  float _2730 = _2727 + 1.0f;
  float _2731 = _2728 + 1.0f;
  float _2732 = _2729 + 1.0f;
  float _2733 = _2724 / _2730;
  float _2734 = _2725 / _2731;
  float _2735 = _2726 / _2732;
  float _2736 = log2(_2733);
  float _2737 = log2(_2734);
  float _2738 = log2(_2735);
  float _2739 = _2736 * 78.84375f;
  float _2740 = _2737 * 78.84375f;
  float _2741 = _2738 * 78.84375f;
  float _2742 = exp2(_2739);
  float _2743 = exp2(_2740);
  float _2744 = exp2(_2741);
  float _2745 = saturate(_2742);
  float _2746 = saturate(_2743);
  float _2747 = saturate(_2744);
  SV_Target.x = _1954;
  SV_Target.y = _1955;
  SV_Target.z = _1956;
  SV_Target.w = _1911;
  SV_Target_1.x = _325;
  SV_Target_1.y = _326;
  SV_Target_1.z = _327;
  SV_Target_1.w = _328;
  SV_Target_2.x = _2745;
  SV_Target_2.y = _2746;
  SV_Target_2.z = _2747;
  SV_Target_2.w = 1.0f;
  SV_Target_3.x = _78.w;
  SV_Target_3.y = _78.w;
  SV_Target_3.z = _78.w;
  SV_Target_3.w = _78.w;
  OutputSignature output_signature = { SV_Target, SV_Target_1, SV_Target_2, SV_Target_3 };
  return output_signature;
}
