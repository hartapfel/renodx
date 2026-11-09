// Supplies the exact native sky pixel interfaces over a deterministic test view.
cbuffer NativeFrame:register(b12) {float4 frame[341];}
struct SkyVertex {
  float4 uv:TEXCOORD0;
  float4 world:TEXCOORD1;
  float4 position:SV_Position;
};
SkyVertex main(uint id:SV_VertexID) {
  float2 uv=float2((id<<1u)&2u,id&2u);
  float2 ndc=uv*float2(2,-2)+float2(-1,1);
  float3 view=float3((ndc-frame[15].xy)/float2(frame[13].x,frame[14].y),1);
  float3 ray=float3(dot(view,frame[1].xyz),dot(view,frame[2].xyz),dot(view,frame[3].xyz));
  float3 world=frame[0].xyz+ray*1000.f;
  SkyVertex result;
  result.position=float4(ndc,0,1);
  result.uv=float4(uv,world.xy);
  result.world=float4(world,world.z);
  return result;
}
