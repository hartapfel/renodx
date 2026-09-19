// Position/opacity replay audited from F53BF32F (trunks) and 9E55FEF3 (leaves).
// Their vertex layout has TEXCOORD inputs instead of POSITION. Current native
// constants stay at their original registers; previous c95-c219 use the VTF.
float4 current_clip_rows[4] : register(c0);
float4 world_rows[4] : register(c8);
float4 eye : register(c12);
float4 origin : register(c13);
float4 clip_plane : register(c18);
float4 tree_info : register(c19);  // x: trunk=1/leaves=2, w: native vertex alpha
float4 previous_origin : register(c21);
float4 previous_eye : register(c22);
float4 previous_palette_info : register(c24);
float4 constants[125] : register(c95);
sampler2D previous_constants : register(s0);

float4 TreeConstant(int index, bool previous) {
  if (previous) return tex2Dlod(previous_constants, float4((index - 95.f + .5f) / 128.f, previous_palette_info.x, 0.f, 0.f));
  return constants[index - 95];
}

float3 TreePosition(float4 uv, float4 stencil, float4 tangent, float4 packed, float4 binormal, bool previous) {
  float4 compression = TreeConstant(120, previous);
  precise float3 local = mad(packed.xyz, compression.y, compression.x);
  float3 eye_position = previous ? previous_eye.xyz : eye.xyz;
  precise float inverse_distance = rsqrt(dot(eye_position, eye_position));
  precise float distance = rcp(inverse_distance) * TreeConstant(96, previous).x;
  [branch] if (tree_info.x == 1.f) {
    precise float3 direction = binormal.zxy * tangent.yzx;
    direction = mad(binormal.yzx, tangent.zxy, -direction);
    precise float3 second = direction.yzx * binormal.zxy;
    second = mad(binormal.yzx, direction.zxy, -second);
    float selector = dot(stencil.xyz, TreeConstant(208, previous).xyz);
    float fraction = frac(selector);
    selector = mad(selector < -selector ? 1.f : 0.f, -fraction < fraction ? 1.f : 0.f, selector - fraction);
    float4 table = TreeConstant(150 + int(round(selector)), previous);
    float4 factors = TreeConstant(209, previous);
    precise float fade = saturate(mad(factors.x, distance, factors.y));
    precise float amount = mad(packed.w, compression.z, 0.000000999999997f);
    precise float morph = fade * TreeConstant(207, previous).x;
    morph = mad(morph, table.z, 1.f);
    amount *= morph;
    precise float level = rcp(stencil.w) * TreeConstant(210, previous).x;
    precise float keep = mad(level >= 1.f ? 1.f : 0.f, -fade, 1.f);
    amount *= keep;
    direction *= table.x;
    direction = mad(table.y, second, direction);
    local = mad(amount, direction, local);
  } else {
    precise float radius = packed.w * tangent.x;
    precise float3 direction = mad(stencil.xyz, 2.f, -1.f);
    direction *= radius;
    precise float2 facing = inverse_distance * eye_position.xy;
    precise float selector = mad(stencil.w, 255.f, .5f);
    float4 factors = TreeConstant(213, previous);
    float fade = saturate(mad(distance, factors.x, factors.y));
    precise float2 selected = lerp(float2(selector, fade), float2(mad(stencil.w, 255.f, -99.5f), 0.f), selector > 99.f ? 1.f : 0.f);
    precise float horizontal = mad(uv.x, 2.f, -1.f);
    precise float vertical = mad(uv.y, 2.f, -1.f);
    float3 side = float3(-facing.y, facing.x, vertical);
    precise float3 billboard = rsqrt(dot(side, side)) * side;
    billboard *= horizontal;
    float4 equation = TreeConstant(214 + int(round(selected.x - frac(selector))), previous);
    precise float amount = mad(min(max(distance, equation.x), equation.y), equation.z, equation.w);
    amount *= packed.w;
    direction *= amount;
    amount *= tangent.x;
    billboard = mad(amount, billboard, -direction);
    direction = mad(selected.y, billboard, direction);
    local += direction;
  }
  float3 seed = local + (previous ? previous_origin.xyz : origin.xyz);
  float phase0 = dot(TreeConstant(102, previous).xyz, seed) + TreeConstant(101, previous).x;
  float phase1 = dot(seed, TreeConstant(103, previous).xyz) + TreeConstant(104, previous).x;
  precise float3 wind = sin(phase1) * TreeConstant(105, previous).xyz;
  wind = mad(TreeConstant(100, previous).xyz, sin(phase0), wind);
  return local + wind;
}

struct Output {
  precise float4 position : POSITION;
  float4 current_clip : TEXCOORD0;
  precise float3 previous_position : TEXCOORD1;
  float clip_distance : TEXCOORD2;
  float2 uv : TEXCOORD3;
  float4 color : COLOR0;
};
Output main(float4 uv : TEXCOORD0, float4 stencil : TEXCOORD1, float4 tangent : TEXCOORD2,
            float4 packed : TEXCOORD4, float4 binormal : TEXCOORD5) {
  Output output;
  float4 local = float4(TreePosition(uv, stencil, tangent, packed, binormal, false), 1.f);
  output.previous_position = TreePosition(uv, stencil, tangent, packed, binormal, true);
  output.position = float4(dot(local, current_clip_rows[0]), dot(local, current_clip_rows[1]),
                          dot(local, current_clip_rows[2]), dot(local, current_clip_rows[3]));
  output.current_clip = output.position;
  float3 world = float3(dot(local, world_rows[0]), dot(local, world_rows[1]), dot(local, world_rows[2]));
  output.clip_distance = dot(world, clip_plane.xyz) - clip_plane.w;
  output.uv = uv.zw;
  [branch] if (tree_info.x == 1.f) output.uv = mad(uv.xy, constants[211 - 95].y, constants[211 - 95].x);
  output.color = float4(1.f, 1.f, 1.f, tree_info.w);
  return output;
}
