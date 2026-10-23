#include "./rigid_vertex.hlsli"

// Previous poses are keyed by persistent native allocations, not draw order.
struct BoneMatrix { float4 column[4]; };
struct ObjectPose {
  float4 world[3];
  uint previous_base, bone_count, valid, palette_valid;
};
StructuredBuffer<BoneMatrix> PreviousBones : register(t120);
StructuredBuffer<uint> PaletteLookup : register(t121);
StructuredBuffer<ObjectPose> PreviousPoses : register(t122);
Texture2D<float4> PreviousReference : register(t123);

float4 TransformPreviousBone(uint index, float4 position) {
  const BoneMatrix bone = PreviousBones[index];
  // Native shaders use element 15 for shading metadata, then replace it with
  // 1 for position transforms. Treating it as homogeneous W moves even a
  // stationary vertex when the metadata changes.
  return position.x * bone.column[0] + position.y * bone.column[1]
         + position.z * bone.column[2] + position.w * float4(bone.column[3].xyz, 1.f);
}

float4 PreviousObjectClip(float3 position, uint4 indices, float4 weights,
                          float4 skinning, float reference_blend, uint instance, out float valid) {
  // Classic routes moving rigid props through skin permutations too. Palette
  // zero is the captured identity matrix and stride zero disables all bones.
  if (skinning.x == 0.f && skinning.y == 0.f) {
    if (reference_blend < 1.f) {
      uint width, height;
      PreviousReference.GetDimensions(width, height);
      if (indices.x >= width || height != 1) { valid = 0.f; return float4(0, 0, 0, -1); }
      position = lerp(PreviousReference.Load(int3(indices.x, 0, 0)).xyz, position, reference_blend);
    }
    return PreviousRigidClip(position, instance, valid);
  }
  uint count, stride;
  PaletteLookup.GetDimensions(count, stride);
  const uint base = (uint)skinning.x;
  const uint entry = base < count ? PaletteLookup[base] : 0;
  const ObjectPose pose = PreviousPoses[entry];
  RigidPose instance_pose = (RigidPose)0;
  if (instance_history != 0 && instance < rigid_count) instance_pose = PreviousRigidPoses[instance];
  valid = entry != 0 && (instance_history != 0 ? pose.palette_valid != 0 && instance_pose.valid != 0 : pose.valid != 0) && skinning.y == 1.f
          && all((indices < pose.bone_count) | (weights == 0.f)) && dot(weights, 1.f) > 1e-8f;
  if (valid == 0.f) return float4(0, 0, 0, -1);
  indices = min(indices, pose.bone_count - 1);
  weights /= dot(weights, 1.f);
  float4 local =
      TransformPreviousBone(pose.previous_base + indices.x, float4(position, 1)) * weights.x
      + TransformPreviousBone(pose.previous_base + indices.y, float4(position, 1)) * weights.y
      + TransformPreviousBone(pose.previous_base + indices.z, float4(position, 1)) * weights.z
      + TransformPreviousBone(pose.previous_base + indices.w, float4(position, 1)) * weights.w;
  if (reference_blend < 1.f) {
    uint width, height;
    PreviousReference.GetDimensions(width, height);
    if (indices.x >= width || height != 1) { valid = 0.f; return float4(0, 0, 0, -1); }
    const float3 reference = PreviousReference.Load(int3(indices.x, 0, 0)).xyz;
    const float3 attached = TransformPreviousBone(pose.previous_base + indices.x, float4(reference, 1)).xyz;
    local.xyz = lerp(attached, local.xyz, reference_blend);
  }
  const float4 world = instance_history != 0
      ? float4(dot(instance_pose.world[0], local), dot(instance_pose.world[1], local), dot(instance_pose.world[2], local), local.w)
      : float4(dot(pose.world[0], local), dot(pose.world[1], local), dot(pose.world[2], local), local.w);
  float4 clip = float4(dot(previous_view[0], world), dot(previous_view[1], world),
                      dot(previous_view[2], world), dot(previous_view[3], world));
  clip.xy -= previous_frame[15].xy * clip.w;
  return clip;
}
