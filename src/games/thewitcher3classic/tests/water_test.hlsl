// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#include "../water/shading.hlsli"
#include "../water/transport.hlsli"
Texture2D<float4> Depth : register(t15);
float4 main(float4 position : SV_Position) : SV_Target {
  float x=floor(position.x)/63.f;
  if (position.y<1.f) return float4(WaterFresnel(x),WaterTransmittance(float3(.1,.2,.3),x*20.f));
  if (position.y<2.f) return float4(WaterScatterIntegral(float3(0,.000001,.3),x*20.f),1);
  if (position.y<3.f) return float4(WaterSpecular(float3(0,0,1),normalize(float3(x,0,1)),float3(0,0,1),.1),0,0,1);
  return ShadeClassicWater(Depth,position,float3(0,0,0),float3(0,0,1),float3(0,0,1),0.f,1.f,position.x>=32.f ? float3(.25,.5,.75) : 0.f,0.f,float4(1,2,3,.25));
}

float4 trace(float4 position:SV_Position):SV_Target {
  return WaterRefraction(Depth,position,float3(0,0,0),normalize(ClassicWaterFrame[50].xyz),float3(.5,.5,.5));
}

float4 night_lighting(float4 position:SV_Position):SV_Target {
  uint row=(uint)position.y;
  float3 sun=(row==1 || row==3) ? float3(4,8,16) : 0.f;
  float3 ambient=(row==0 || row==3) ? float3(.25,.5,.75) : 0.f;
  return ShadeClassicWater(Depth,position,float3(0,0,0),float3(0,0,1),float3(0,0,1),
      sun,1.f,ambient,row==3 ? 1.f : 0.f,float4(1,2,3,.25));
}

float4 atmosphere(float4 position:SV_Position):SV_Target {
  float height=lerp(-50.f,100.f,floor(position.x)/63.f);
  float falloff=.0233f;
  float3 directions=float3(.392f,-.3f,0.f);
  if(position.y>=1.f) {height+=2188.528427f;falloff=.00223805698f;}
  if(position.y>=2.f) directions=float3(.000001f,-.000001f,0.f);
  if(position.y>=3.f) {height+=1.e7f;falloff=1.e-7f;}
  return float4(FogLightTransmittance(height,directions.x,.004f,falloff,1000.f),
      FogLightTransmittance(height,directions.y,.004f,falloff,1000.f),
      FogLightTransmittance(height,directions.z,.004f,falloff,1000.f),
      FogLightTransmittance(height,.392f,0.f,falloff,1000.f));
}

float4 underwater_transport(float4 position:SV_Position):SV_Target {
  float x=floor(position.x)/63.f;
  if(position.y<1.f)
    return float4(WaterInterfaceFresnel(x,1.333f),WaterInterfaceFresnel(x,1.f/1.333f),
        WaterPhase(2.f*x-1.f,.5f),WaterPhase(2.f*x-1.f,0.f));
  float distance=40.f*x;
  float3 extinction=float3(0.f,.01f,.3594f);
  if(position.y<2.f)
    return float4(WaterSunCell(extinction,0.f,distance,50.f,50.f-1.2f*distance),1.f);
  if(position.y<3.f)
    return float4(WaterSunCell(extinction,0.f,distance,50.f,50.f-distance),1.f);
  // HDR source and opposed light/view directions. Split-vs-unsplit integration
  // must agree; no clipping of radiance to SDR and no loss from cancellation.
  return float4(32.f*.2f*WaterSunCell(extinction,0.f,distance,2.f,2.f+distance),1.f);
}
