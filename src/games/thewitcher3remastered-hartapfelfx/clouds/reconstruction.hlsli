// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#ifndef CLASSIC_CLOUD_RECONSTRUCTION
#define CLASSIC_CLOUD_RECONSTRUCTION
// Separable Catmull-Rom: combine the two positive middle weights with a
// bilinear fetch, reducing sixteen taps to nine. Interpolating history with a
// tent filter every frame repeatedly diffuses cloud detail. Callers constrain
// negative-lobe overshoot using their current, linear-HDR neighbourhood.
float4 ReconstructCloud(Texture2D<float4> source,SamplerState filter_sampler,float2 uv,float2 size) {
  float2 pixel=uv*size-.5f,base=floor(pixel),f=frac(pixel);
  float2 w0=f*(-.5f+f*(1.f-.5f*f));
  float2 w1=1.f+f*f*(-2.5f+1.5f*f);
  float2 w2=f*(.5f+f*(2.f-1.5f*f));
  float2 w3=f*f*(-.5f+.5f*f),middle=w1+w2;
  float3 x=float3(base.x-.5f,base.x+.5f+w2.x/middle.x,base.x+2.5f)/size.x;
  float3 y=float3(base.y-.5f,base.y+.5f+w2.y/middle.y,base.y+2.5f)/size.y;
  float3 wx=float3(w0.x,middle.x,w3.x),wy=float3(w0.y,middle.y,w3.y);
  float4 result=0.f;
  [unroll]for(uint j=0;j<3;++j)[unroll]for(uint i=0;i<3;++i)
    result+=source.SampleLevel(filter_sampler,float2(x[i],y[j]),0)*(wx[i]*wy[j]);
  return result;
}
#endif
