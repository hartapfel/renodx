// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
// One-time tileable Perlin-Worley/Worley volume (Nubis, SIGGRAPH 2017).
RWTexture3D<float4> noise : register(u0);
uint Hash(uint3 p) {
  uint h=p.x*1597334677u+p.y*3812015801u+p.z*2798796415u;
  h=(h^(h>>16))*2246822519u;return h^(h>>13);
}
float3 Random(uint3 p) {
  uint h=Hash(p);
  return float3(h&1023u,(h>>10)&1023u,(h>>20)&1023u)/1023.f;
}
float Perlin(float3 p,int period) {
  int3 cell=int3(floor(p));float3 f=frac(p),w=f*f*f*(f*(f*6.f-15.f)+10.f);
  float value=0.f;
  [unroll]for(int z=0;z<2;++z)[unroll]for(int y=0;y<2;++y)[unroll]for(int x=0;x<2;++x) {
    int3 o=int3(x,y,z);
    float3 g=normalize(Random(uint3((cell+o+period)%period))*2.f-1.f+1.e-4f);
    float3 blend=lerp(1.f-w,w,float3(o));
    value+=dot(g,f-float3(o))*blend.x*blend.y*blend.z;
  }
  return saturate(.5f+.8f*value);
}
float Worley(float3 p,int period) {
  int3 cell=int3(floor(p));float3 f=frac(p);float nearest=3.f;
  [unroll]for(int z=-1;z<=1;++z)[unroll]for(int y=-1;y<=1;++y)[unroll]for(int x=-1;x<=1;++x) {
    int3 o=int3(x,y,z);
    float3 delta=float3(o)+Random(uint3((cell+o+period)%period))-f;
    nearest=min(nearest,dot(delta,delta));
  }
  return saturate(1.f-sqrt(nearest));
}
[numthreads(4,4,4)]
void main(uint3 id:SV_DispatchThreadID) {
  uint width,height,depth;noise.GetDimensions(width,height,depth);
  if(any(id>=uint3(width,height,depth)))return;
  float3 uv=(id+.5f)/float3(width,height,depth);
  // Periodic divergence-free domain displacement breaks the cellular lattice.
  // This is a procedural turbulence approximation, not a fluid simulation.
  float3 warped=frac(uv+.045f*sin(6.28318530718f*uv.yzx)
      +.018f*sin(12.56637061436f*uv.zxy));
  float p4=Perlin(warped*4,4);
  float perlin=.625f*p4+.25f*Perlin(warped*8,8)+.125f*Perlin(warped*16,16);
  float w4=Worley(warped*4,4),w8=Worley(warped*8,8);
  float w16=Worley(warped*16,16),w32=Worley(warped*32,32);
  float potential=saturate((perlin-.35f*(1.f-w4))/.65f);
  // Separate formation potential, billows, erosion and broad column variation.
  // Preserve the inter-scale structure instead of baking everything into a
  // biased scalar and leaving two channels unused (Nubis 2017/2022).
  noise[id]=float4(saturate(.5f+(potential-.5f)*1.6f),
      .625f*w4+.25f*w8+.125f*w16,
      .625f*w8+.25f*w16+.125f*w32,
      .65f*Perlin(uv*2,2)+.35f*p4);
}
