struct RigidPose { float4 world[3]; uint unused0, unused1, valid, unused2; };
StructuredBuffer<RigidPose> PreviousRigidPoses : register(t125);
cbuffer RigidMetadata : register(b8) { uint rigid_count, instance_history; }
cbuffer PreviousView : register(b10) { float4 previous_view[16]; }
cbuffer PreviousFrame : register(b11) { float4 previous_frame[269]; }

float4 PreviousRigidClip(float3 position, uint instance, out float valid) {
  if (instance >= rigid_count) { valid = 0; return float4(0, 0, 0, -1); }
  const RigidPose pose = PreviousRigidPoses[instance];
  valid = pose.valid != 0;
  const float4 local = float4(position, 1);
  const float4 world = float4(dot(pose.world[0], local), dot(pose.world[1], local), dot(pose.world[2], local), 1);
  float4 clip = float4(dot(previous_view[0], world), dot(previous_view[1], world),
                      dot(previous_view[2], world), dot(previous_view[3], world));
  clip.xy -= previous_frame[15].xy * clip.w;
  return clip;
}
