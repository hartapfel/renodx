// Authored velocity replay for the audited native rigid position path.
float4 current_clip_rows[4] : register(c0);
float4 world_rows[4] : register(c8);
float4 clip_plane : register(c18);
float4 position_info : register(c19);
float4 vertex_uv_scale : register(c20);
float4 wind_origin : register(c13);
float4 previous_wind_origin : register(c21);
float4 wind[6] : register(c100);
float4 previous_wind[6] : register(c140);
float4 geometry_info : register(c23);

// Native BDF4BDE9 applies two position-seeded sine oscillators before WVP.
float3 WindPosition(float3 local, float3 origin, float4 parameters[6]) {
  float3 seed = local + origin;
  float phase0 = dot(parameters[2].xyz, seed) + parameters[1].x;
  float phase1 = dot(seed, parameters[3].xyz) + parameters[4].x;
  precise float3 offset = sin(phase1) * parameters[5].xyz;
  offset = mad(parameters[0].xyz, sin(phase0), offset);
  return local + offset;
}

struct Output {
  precise float4 position : POSITION;
  float4 current_clip : TEXCOORD0;
  precise float3 previous_position : TEXCOORD1;
  float clip_distance : TEXCOORD2;
  float2 uv : TEXCOORD3;
  float4 color : COLOR0;
};

Output main(float4 position : POSITION, float2 uv : TEXCOORD0, float4 color : COLOR0, float4 previous_vertex : TEXCOORD5) {
  Output output;
  output.uv = uv * vertex_uv_scale.xy;
  output.color = position_info.y != 0.f ? color : position_info.w;
  float4 local = float4(position.xyz, 1.f);
  [branch] if (position_info.x != 0.f) local.xyz *= abs(position.w * 3.81481368e-006f);
  output.previous_position = local.xyz;
  [branch] if (geometry_info.x != 0.f) {
    output.previous_position = previous_vertex.xyz;
    [branch] if (position_info.x != 0.f) output.previous_position *= abs(previous_vertex.w * 3.81481368e-006f);
  }
  [branch] if (position_info.z != 0.f) {
    output.previous_position = WindPosition(output.previous_position, previous_wind_origin.xyz, previous_wind);
    local.xyz = WindPosition(local.xyz, wind_origin.xyz, wind);
  }
  output.position = float4(dot(current_clip_rows[0], local), dot(current_clip_rows[1], local),
                           dot(current_clip_rows[2], local), dot(current_clip_rows[3], local));
  output.current_clip = output.position;
  float3 world = float3(dot(world_rows[0], local), dot(world_rows[1], local), dot(world_rows[2], local));
  output.clip_distance = dot(world, clip_plane.xyz) - clip_plane.w;
  return output;
}
