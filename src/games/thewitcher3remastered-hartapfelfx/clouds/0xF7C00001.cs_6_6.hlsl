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
  // Bake irregular, tileable domain warping once. This is procedural
  // turbulence, not a physical fluid simulation or a divergence-free field.
  float3 warp=float3(Perlin(uv*4,4),Perlin(uv.yzx*4+7.f,4),
      Perlin(uv.zxy*4+13.f,4))-.5f;
  float3 warped=frac(uv+.16f*warp);
  float p4=Perlin(warped*4,4);
  float perlin=.625f*p4+.25f*Perlin(warped*8,8)+.125f*Perlin(warped*16,16);
  float w4=Worley(warped*4,4),w8=Worley(warped*8,8);
  float w16=Worley(warped*16,16);
  float potential=saturate((perlin-.25f*(1.f-w4))/.75f);
  // R: formation potential. G/B: independent billow scales, rather than
  // repeatedly sampling the same already-averaged cellular fBm. A: wisps.
  // No 32-cell octave in a 64-voxel tile: it had only two texels per feature.
  // The density sampler nests these scales inside the parent envelope.
  noise[id]=float4(saturate(.5f+(potential-.5f)*1.8f),
      saturate(w4*1.5f),saturate((.7f*w8+.3f*w16)*1.5f),
      saturate(.5f+1.8f*(.65f*Perlin(warped*8,8)+.35f*Perlin(warped*16,16)-.5f)));
}
