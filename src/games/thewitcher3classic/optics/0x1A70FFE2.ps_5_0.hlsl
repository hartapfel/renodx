// Native camera-blur composite bypass. Keep the sharp input and alpha contract.
Texture2D<float4> Scene : register(t0);
float4 main(float4 position : SV_Position) : SV_Target { return float4(Scene.Load(int3(position.xy,0)).rgb,1); }
