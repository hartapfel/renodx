/* Copyright (C) 2026 Hartapfel
 * SPDX-License-Identifier: MIT
 */
#include "celestial.hlsli"

cbuffer cb12 : register(b12) {
  uint sun_size_bits : packoffset(c206.w);
  uint cb12_padding : packoffset(c340.w);
};

cbuffer cb1 : register(b1) {
  float cb1_036x : packoffset(c036.x);
  float cb1_036y : packoffset(c036.y);
  float cb1_036z : packoffset(c036.z);
  float cb1_045x : packoffset(c045.x);
  float cb1_045y : packoffset(c045.y);
  float cb1_045z : packoffset(c045.z);
  float cb1_045w : packoffset(c045.w);
  float cb1_046x : packoffset(c046.x);
  float cb1_046y : packoffset(c046.y);
  float cb1_046z : packoffset(c046.z);
  float cb1_046w : packoffset(c046.w);
  float cb1_047x : packoffset(c047.x);
  float cb1_047y : packoffset(c047.y);
  float cb1_047z : packoffset(c047.z);
  float cb1_047w : packoffset(c047.w);
  float cb1_048x : packoffset(c048.x);
  float cb1_048y : packoffset(c048.y);
  float cb1_048z : packoffset(c048.z);
  float cb1_048w : packoffset(c048.w);
  uint cb1_padding : packoffset(c53.w);
};

cbuffer cb2 : register(b2) {
  row_major float4x4 FrequentVertexConsts_000 : packoffset(c000.x);
  row_major float4x4 FrequentVertexConsts_064 : packoffset(c004.x);
  float4 FrequentVertexConsts_128 : packoffset(c008.x);
  float4 FrequentVertexConsts_144 : packoffset(c009.x);
  float4 FrequentVertexConsts_160 : packoffset(c010.x);
  float4 FrequentVertexConsts_176 : packoffset(c011.x);
  float4 FrequentVertexConsts_192 : packoffset(c012.x);
};

struct OutputSignature {
  linear float3 output_TEXCOORD : TEXCOORD;
  linear float3 TEXCOORD_1 : TEXCOORD1;
  noperspective float4 SV_Position : SV_Position;
};

OutputSignature main(
  float3 POSITION : POSITION,
  float2 TEXCOORD : TEXCOORD,
  float3 NORMAL : NORMAL,
  float4 TANGENT : TANGENT
) {
  float3 output_TEXCOORD = 0;
  float3 TEXCOORD_1 = 0;
  float4 SV_Position = 0;
  float _35 = (POSITION.x * FrequentVertexConsts_128.x) + FrequentVertexConsts_144.x;
  float _36 = (POSITION.y * FrequentVertexConsts_128.y) + FrequentVertexConsts_144.y;
  float _37 = (POSITION.z * FrequentVertexConsts_128.z) + FrequentVertexConsts_144.z;
  // Resize the sun disk before projection; keep its normals and radiance native.
  float3 sun_position = ScaleCelestialPosition(float3(_35, _36, _37),
      FrequentVertexConsts_128.xyz, FrequentVertexConsts_144.xyz, sun_size_bits, WITCHER_SUN_TAG);
  _35 = sun_position.x;
  _36 = sun_position.y;
  _37 = sun_position.z;
  float _74 = (FrequentVertexConsts_000[0].w) - cb1_036x;
  float _75 = (FrequentVertexConsts_000[1].w) - cb1_036y;
  float _76 = (FrequentVertexConsts_000[2].w) - cb1_036z;
  float _160 = (NORMAL.x * 2.0f) + -1.0f;
  float _161 = (NORMAL.y * 2.0f) + -1.0f;
  float _162 = (NORMAL.z * 2.0f) + -1.0f;
  float _165 = mad(_162, (FrequentVertexConsts_000[0].z), mad(_161, (FrequentVertexConsts_000[0].y), ((FrequentVertexConsts_000[0].x) * _160)));
  float _168 = mad(_162, (FrequentVertexConsts_000[1].z), mad(_161, (FrequentVertexConsts_000[1].y), ((FrequentVertexConsts_000[1].x) * _160)));
  float _171 = mad(_162, (FrequentVertexConsts_000[2].z), mad(_161, (FrequentVertexConsts_000[2].y), ((FrequentVertexConsts_000[2].x) * _160)));
  float _173 = rsqrt(dot(float3(_165, _168, _171), float3(_165, _168, _171)));
  output_TEXCOORD.x = (_173 * _165);
  output_TEXCOORD.y = (_173 * _168);
  output_TEXCOORD.z = (_173 * _171);
  TEXCOORD_1.x = (mad(_37, (FrequentVertexConsts_000[0].z), mad(_36, (FrequentVertexConsts_000[0].y), (_35 * (FrequentVertexConsts_000[0].x)))) + (FrequentVertexConsts_000[0].w));
  TEXCOORD_1.y = (mad(_37, (FrequentVertexConsts_000[1].z), mad(_36, (FrequentVertexConsts_000[1].y), (_35 * (FrequentVertexConsts_000[1].x)))) + (FrequentVertexConsts_000[1].w));
  TEXCOORD_1.z = (mad(_37, (FrequentVertexConsts_000[2].z), mad(_36, (FrequentVertexConsts_000[2].y), (_35 * (FrequentVertexConsts_000[2].x)))) + (FrequentVertexConsts_000[2].w));
  SV_Position.x = mad(1.0f, mad(1.0f, cb1_045w, mad(_76, cb1_045z, mad(_75, cb1_045y, (cb1_045x * _74)))), mad(_37, mad(0.0f, cb1_045w, mad((FrequentVertexConsts_000[2].z), cb1_045z, mad((FrequentVertexConsts_000[1].z), cb1_045y, ((FrequentVertexConsts_000[0].z) * cb1_045x)))), mad(_36, mad(0.0f, cb1_045w, mad((FrequentVertexConsts_000[2].y), cb1_045z, mad((FrequentVertexConsts_000[1].y), cb1_045y, ((FrequentVertexConsts_000[0].y) * cb1_045x)))), (_35 * mad(0.0f, cb1_045w, mad((FrequentVertexConsts_000[2].x), cb1_045z, mad((FrequentVertexConsts_000[1].x), cb1_045y, ((FrequentVertexConsts_000[0].x) * cb1_045x))))))));
  SV_Position.y = mad(1.0f, mad(1.0f, cb1_046w, mad(_76, cb1_046z, mad(_75, cb1_046y, (cb1_046x * _74)))), mad(_37, mad(0.0f, cb1_046w, mad((FrequentVertexConsts_000[2].z), cb1_046z, mad((FrequentVertexConsts_000[1].z), cb1_046y, ((FrequentVertexConsts_000[0].z) * cb1_046x)))), mad(_36, mad(0.0f, cb1_046w, mad((FrequentVertexConsts_000[2].y), cb1_046z, mad((FrequentVertexConsts_000[1].y), cb1_046y, ((FrequentVertexConsts_000[0].y) * cb1_046x)))), (_35 * mad(0.0f, cb1_046w, mad((FrequentVertexConsts_000[2].x), cb1_046z, mad((FrequentVertexConsts_000[1].x), cb1_046y, ((FrequentVertexConsts_000[0].x) * cb1_046x))))))));
  SV_Position.z = mad(1.0f, mad(1.0f, cb1_047w, mad(_76, cb1_047z, mad(_75, cb1_047y, (cb1_047x * _74)))), mad(_37, mad(0.0f, cb1_047w, mad((FrequentVertexConsts_000[2].z), cb1_047z, mad((FrequentVertexConsts_000[1].z), cb1_047y, ((FrequentVertexConsts_000[0].z) * cb1_047x)))), mad(_36, mad(0.0f, cb1_047w, mad((FrequentVertexConsts_000[2].y), cb1_047z, mad((FrequentVertexConsts_000[1].y), cb1_047y, ((FrequentVertexConsts_000[0].y) * cb1_047x)))), (_35 * mad(0.0f, cb1_047w, mad((FrequentVertexConsts_000[2].x), cb1_047z, mad((FrequentVertexConsts_000[1].x), cb1_047y, ((FrequentVertexConsts_000[0].x) * cb1_047x))))))));
  SV_Position.w = mad(1.0f, mad(1.0f, cb1_048w, mad(_76, cb1_048z, mad(_75, cb1_048y, (cb1_048x * _74)))), mad(_37, mad(0.0f, cb1_048w, mad((FrequentVertexConsts_000[2].z), cb1_048z, mad((FrequentVertexConsts_000[1].z), cb1_048y, ((FrequentVertexConsts_000[0].z) * cb1_048x)))), mad(_36, mad(0.0f, cb1_048w, mad((FrequentVertexConsts_000[2].y), cb1_048z, mad((FrequentVertexConsts_000[1].y), cb1_048y, ((FrequentVertexConsts_000[0].y) * cb1_048x)))), (_35 * mad(0.0f, cb1_048w, mad((FrequentVertexConsts_000[2].x), cb1_048z, mad((FrequentVertexConsts_000[1].x), cb1_048y, ((FrequentVertexConsts_000[0].x) * cb1_048x))))))));
  OutputSignature output_signature = { output_TEXCOORD, TEXCOORD_1, SV_Position };
  return output_signature;
}
