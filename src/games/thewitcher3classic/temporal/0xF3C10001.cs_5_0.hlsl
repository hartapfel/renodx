// Private GPU preparation pass; not a replacement for a native game hash.
Texture2D<float3> Scene : register(t0);
Texture2D<float> NativeDepth : register(t1);
Texture2D<float2> Objects : register(t2);
// Magnitude is native depth; its sign marks unavailable object history.
Texture2D<float> ObjectDepth : register(t3);
RWTexture2D<float4> Color : register(u0);
RWTexture2D<float> Depth : register(u1);
RWTexture2D<float2> Motion : register(u2);
RWTexture2D<float> Responsive : register(u3);

cbuffer Camera : register(b10) { float4 camera[180]; }
cbuffer Frame : register(b12) { float4 frame[269]; }

[numthreads(8, 8, 1)]
void main(uint3 id : SV_DispatchThreadID) {
  uint2 size;
  Color.GetDimensions(size.x, size.y);
  if (any(id.xy >= size)) return;
  const int3 pixel = int3(id.xy, 0);
  const float raw_depth = NativeDepth.Load(pixel);
  // Native projection displacement is -camera[0].xy pixels. Remove that
  // displacement before the unjittered camera reprojection, retaining raw MVs.
  const float2 current_uv = (id.xy + 0.5f + camera[0].xy) / size;
  const float2 ndc = current_uv * 2.f - 1.f;
  const float z = raw_depth * frame[22].x + frame[22].y;
  const float4 previous_clip = camera[78] * ndc.x - camera[79] * ndc.y + camera[80] * z + camera[81];
  const bool valid = all(isfinite(previous_clip)) && previous_clip.w > 1e-6f;
  const float2 previous_uv = previous_clip.xy / max(previous_clip.w, 1e-6f) * float2(0.5f, -0.5f) + 0.5f;
  const float2 camera_motion = previous_uv - current_uv;
  uint object_width, object_height;
  ObjectDepth.GetDimensions(object_width, object_height);
  const float object_depth = object_width >= size.x && object_height >= size.y ? ObjectDepth.Load(pixel) : -2.f;
  const bool object_hit = abs(object_depth) <= 1.f && abs(abs(object_depth) - raw_depth) <= 2e-7f;
  const bool object_history = (asuint(object_depth) & 0x80000000u) == 0;
  float2 motion = object_hit ? Objects.Load(pixel) : camera_motion;
  const bool motion_valid = (object_hit ? object_history : valid) && all(isfinite(motion)) && all(abs(motion) <= 1.f);
  motion = motion_valid ? motion : 0.f;
  const float3 source = Scene.Load(pixel);
  Color[id.xy] = float4(min(isfinite(source) ? max(source, 0.f) : 0.f, 65504.f), 1.f);
  Depth[id.xy] = isfinite(raw_depth) ? saturate(raw_depth) : 0.f;
  Motion[id.xy] = motion;
  Responsive[id.xy] = motion_valid ? 0.f : 1.f;
}
