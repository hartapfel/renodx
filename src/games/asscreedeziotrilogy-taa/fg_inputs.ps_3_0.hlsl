/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#include "./taa_dense_motion.hlsli"
sampler2D depth_texture : register(s0);
sampler2D object_texture : register(s1);
float4 previous_clip_rows[4] : register(c0);
float4 size_jitter : register(c4);
float4 input_info : register(c5); // object enabled, unused, camera pair, unused
struct Inputs { float4 motion : COLOR0; float4 depth : COLOR1; };
Inputs main(float2 uv : TEXCOORD0) {
  // Use the same native raster grid as DLAA's depth/motion inputs. A point
  // sample cannot undo subpixel projection jitter at silhouettes. Report that
  // jitter separately to Streamline instead of pretending this grid is unjittered.
  float2 source_uv = uv;
  float4 object = input_info.x != 0.f ? tex2D(object_texture, source_uv) : 0.f;
  float depth = CurrentMotionDepth(tex2D(depth_texture, source_uv).r, object.w);
  Inputs result;
  result.motion = DenseMotion(source_uv, depth, object, size_jitter, previous_clip_rows, input_info.z != 0.f);
  result.depth = saturate(depth);
  return result;
}
