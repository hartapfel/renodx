// Position-only replay audited against native 6ADF3971 / 73550BE7 / 91F6EBFA.
// Native positions are scaled by 10, indices are unnormalized bone indices,
// and each of the 42 bones occupies three float4 rows at c120.
float4 current_clip_rows[4] : register(c0);
float4 world_rows[4] : register(c8);
float4 clip_plane : register(c18);
float4 vertex_uv_scale : register(c20);
float4 position_info : register(c19);
float4 displacement_info : register(c22);
float4 geometry_info : register(c23);
// Center of this draw's row in the once-per-frame previous-pose atlas.
float4 previous_palette_info : register(c24);
float4 current_bones[126] : register(c120);
sampler2D previous_bones : register(s0);

float3 SkinCurrent(float4 position, int row) {
  return float3(dot(current_bones[row], position), dot(current_bones[row + 1], position),
                dot(current_bones[row + 2], position));
}

float3 SkinPrevious(float4 position, float row) {
  return float3(dot(tex2Dlod(previous_bones, float4((row + 0.5f) / 128.f, previous_palette_info.x, 0.f, 0.f)), position),
                dot(tex2Dlod(previous_bones, float4((row + 1.5f) / 128.f, previous_palette_info.x, 0.f, 0.f)), position),
                dot(tex2Dlod(previous_bones, float4((row + 2.5f) / 128.f, previous_palette_info.x, 0.f, 0.f)), position));
}

struct Output {
  precise float4 position : POSITION;
  float4 current_clip : TEXCOORD0;
  precise float3 previous_position : TEXCOORD1;
  float clip_distance : TEXCOORD2;
  float2 uv : TEXCOORD3;
  float4 color : COLOR0;
};

Output main(float4 position : POSITION, float4 weights : BLENDWEIGHT, float4 indices : BLENDINDICES, float2 uv : TEXCOORD0,
            float4 normal : NORMAL, float4 binormal : BINORMAL, float4 previous_vertex : TEXCOORD5,
            float4 previous_weights : TEXCOORD6, float4 previous_indices : TEXCOORD7,
            float4 previous_normal : TEXCOORD8, float4 previous_binormal : TEXCOORD9) {
  float4 local = float4(position.xyz * 10.f, 1.f);
  float4 previous_local = local;
  [branch] if (geometry_info.x != 0.f) previous_local.xyz = previous_vertex.xyz * 10.f;
  else {
    previous_vertex = position;
    previous_weights = weights;
    previous_indices = indices;
    previous_normal = normal;
    previous_binormal = binormal;
  }
  [branch] if (displacement_info.x != 0.f) {
    // Native 89CCF177 displaces along its decoded normal before skinning.
    float3 direction = (normal.xyz - 127.f) * 0.00787401572f;
    float amount = mad(binormal.w, 0.00392156839f, -0.5f);
    local.xyz = mad(position.xyz, 10.f, direction * (amount * displacement_info.y));
    float3 previous_direction = (previous_normal.xyz - 127.f) * 0.00787401572f;
    float previous_amount = mad(previous_binormal.w, 0.00392156839f, -0.5f);
    previous_local.xyz = mad(previous_vertex.xyz, 10.f, previous_direction * (previous_amount * displacement_info.z));
  }
  int4 rows = int4(indices * 3.f);
  // Keep the native multiply/MAD order, including its unnormalized weights.
  float3 current = SkinCurrent(local, rows.y) * weights.y;
  current = mad(SkinCurrent(local, rows.x), weights.x, current);
  current = mad(SkinCurrent(local, rows.z), weights.z, current);
  current = mad(SkinCurrent(local, rows.w), weights.w, current);
  float4 previous_rows = previous_indices * 3.f;
  float3 previous = SkinPrevious(previous_local, previous_rows.y) * previous_weights.y;
  previous = mad(SkinPrevious(previous_local, previous_rows.x), previous_weights.x, previous);
  previous = mad(SkinPrevious(previous_local, previous_rows.z), previous_weights.z, previous);
  previous = mad(SkinPrevious(previous_local, previous_rows.w), previous_weights.w, previous);
  Output output;
  output.position = float4(dot(current_clip_rows[0], float4(current, 1.f)), dot(current_clip_rows[1], float4(current, 1.f)),
                           dot(current_clip_rows[2], float4(current, 1.f)), dot(current_clip_rows[3], float4(current, 1.f)));
  output.current_clip = output.position;
  output.previous_position = previous;
  output.uv = uv * vertex_uv_scale.xy;
  output.color = 1.f;
  if (position_info.y != 0.f) output.color.a = position.w * 0.99999994f;
  float4 world = float4(dot(world_rows[0], float4(current, 1.f)), dot(world_rows[1], float4(current, 1.f)),
                        dot(world_rows[2], float4(current, 1.f)), dot(world_rows[3], float4(current, 1.f)));
  output.clip_distance = dot(world.xyz / world.w, clip_plane.xyz) - clip_plane.w;
  return output;
}
