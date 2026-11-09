// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#pragma once
#include <array>
#include <algorithm>
#include <cmath>
namespace hartapfelfx::sky {
// Original VS: position = world * (unorm_position * extent + minimum).
// Project its native bound onto the camera plane; no cinematic size constant.
inline float NativeRadius(const std::array<float,40>& vertex,const std::array<float,3>& camera,bool solar) {
  for(float value:vertex)if(!std::isfinite(value))return 0.f;
  std::array<double,3> centre{},direction{},tangent{},bitangent{};
  double distance=0;
  for(unsigned i=0;i<3;++i) {
    double axis=0;
    centre[i]=vertex[4*i+3];
    for(unsigned j=0;j<3;++j) {
      centre[i]+=vertex[4*i+j]*(vertex[36+j]+.5*vertex[32+j]);
      axis+=double(vertex[4*i+j])*vertex[4*i+j];
    }
    if(axis<1.e-12)return 0.f;
    direction[i]=centre[i]-camera[i];distance+=direction[i]*direction[i];
  }
  distance=std::sqrt(distance);
  if(!std::isfinite(distance)||distance<1.f)return 0.f;
  for(double& value:direction)value/=distance;
  tangent=std::abs(direction[2])<.99?std::array<double,3>{-direction[1],direction[0],0}
      :std::array<double,3>{direction[2],0,-direction[0]};
  const double norm=std::sqrt(tangent[0]*tangent[0]+tangent[1]*tangent[1]+tangent[2]*tangent[2]);
  for(double& value:tangent)value/=norm;
  bitangent={direction[1]*tangent[2]-direction[2]*tangent[1],direction[2]*tangent[0]-direction[0]*tangent[2],
      direction[0]*tangent[1]-direction[1]*tangent[0]};
  double a=0,b=0,c=0;
  for(unsigned j=0;j<3;++j) {
    double x=0,y=0;
    for(unsigned i=0;i<3;++i) {
      x+=tangent[i]*vertex[4*i+j]*vertex[32+j]*.5;
      y+=bitangent[i]*vertex[4*i+j]*vertex[32+j]*.5;
    }
    a+=x*x;b+=x*y;c+=y*y;
  }
  double radius=std::sqrt(std::max(0.,.5*(a+c+std::sqrt((a-c)*(a-c)+4*b*b))));
  // E46451D5 emits only where N.V > .5: projected sphere support sqrt(3)/2.
  if(solar)radius*=std::sqrt(.75);
  const double ratio=radius/distance;
  return ratio>1.e-6&&ratio<.5?float(std::asin(ratio)):0.f;
}
} // namespace hartapfelfx::sky
