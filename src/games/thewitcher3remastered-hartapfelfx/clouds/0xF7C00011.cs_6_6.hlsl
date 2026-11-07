// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
// Tileable, anisotropic cirrus material for the single-lookup high layer.
RWTexture2D<float> cirrus : register(u0);
uint Hash(uint2 cell) {
  uint value=cell.x*1597334677u+cell.y*3812015801u;
  value=(value^(value>>16u))*2246822519u;
  return value^(value>>13u);
}
float ValueNoise(float2 uv,uint2 period) {
  float2 p=uv*period;
  int2 cell=int2(floor(p));
  float2 f=frac(p);
  f=f*f*(3.f-2.f*f);
  float4 values;
  [unroll]for(uint y=0;y<2;++y)[unroll]for(uint x=0;x<2;++x) {
    int2 wrapped=(cell+int2(x,y)+int2(period))%int2(period);
    values[y*2u+x]=(Hash(uint2(wrapped))&65535u)/65535.f;
  }
  return lerp(lerp(values.x,values.y,f.x),lerp(values.z,values.w,f.x),f.y);
}
[numthreads(8,8,1)] void main(uint3 id : SV_DispatchThreadID) {
  uint width,height;
  cirrus.GetDimensions(width,height);
  if(id.x>=width ||id.y>=height)return;
  float2 uv=(float2(id.xy)+.5f)/float2(width,height);
  float2 warp=float2(ValueNoise(uv,uint2(2,6)),ValueNoise(uv+float2(.37f,.11f),uint2(2,6)))-.5f;
  uv+=warp*float2(.035f,.012f);
  float field=.42f*ValueNoise(uv,uint2(4,12))+.3f*ValueNoise(uv,uint2(8,24))
      +.2f*ValueNoise(uv,uint2(16,48))+.08f*ValueNoise(uv,uint2(32,96));
  cirrus[id.xy]=smoothstep(.47f,.65f,field);
}
