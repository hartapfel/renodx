// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#ifndef WITCHER_GRAPHICS_WATER_SUN_CONNECTION
#define WITCHER_GRAPHICS_WATER_SUN_CONNECTION
#include "surface_connection.hlsli"
#include "sun_sampling.hlsli"

struct GraphicsWaterSunConnection {
  GraphicsWaterSurfaceCrossing surface;
  GraphicsWaterSunMapping mapping;
  float3 water_tangent;
  float3 water_bitangent;
  float3 air_tangent;
  float3 air_bitangent;
  bool valid;
};

// Differentiate the complete receiver-to-air connection. Curvature moves the
// exit normal as the sampled direction changes; a local Snell Jacobian alone
// misses this focusing term. The field is bilinear, so only h_xy is nonzero.
GraphicsWaterSunConnection GraphicsEvaluateWaterSun(ByteAddressBuffer field, float3 camera,
    float renderer, float3 receiver, float3 water_direction) {
  GraphicsWaterSunConnection result = (GraphicsWaterSunConnection)0;
  result.surface = GraphicsFindWaterSurfaceExit(field,camera,renderer,receiver,water_direction);
  if (!result.surface.valid) return result;
  result.mapping = GraphicsMapWaterSun(water_direction,result.surface.normal,true);
  if (!result.mapping.valid) return result;
  float3 water = result.mapping.water, air = result.mapping.air, normal = result.surface.normal;
  result.water_tangent = normalize(cross(water,abs(water.z)<.9f ? float3(0,0,1) : float3(0,1,0)));
  result.water_bitangent = cross(water,result.water_tangent);
  float water_cosine = dot(water,normal), air_cosine = dot(air,normal);
  const float ior = 1.333f;
  [unroll] for (uint axis=0u;axis<2u;++axis) {
    float3 delta_water = axis==0u ? result.water_tangent : result.water_bitangent;
    float3 delta_position = result.surface.distance*(delta_water-water*(dot(normal,delta_water)/water_cosine));
    float3 delta_raw_normal = float3(-result.surface.mixed_curvature*delta_position.y,
        -result.surface.mixed_curvature*delta_position.x,0.f);
    float3 delta_normal = (delta_raw_normal-normal*dot(normal,delta_raw_normal))*normal.z;
    float delta_cosine = dot(delta_water,normal)+dot(water,delta_normal);
    float3 delta_air = ior*delta_water+(air_cosine-ior*water_cosine)*delta_normal
        + normal*((ior*ior*water_cosine/air_cosine-ior)*delta_cosine);
    if (axis==0u) result.air_tangent=delta_air;
    else result.air_bitangent=delta_air;
  }
  float determinant = abs(dot(cross(result.air_tangent,result.air_bitangent),air));
  if (!isfinite(determinant) || determinant<=1.e-12f) return result;
  result.mapping.solid_angle = 1.f/determinant;
  result.mapping.sample_weight = result.mapping.radiance*result.mapping.solid_angle;
  result.valid = true;
  return result;
}

// Deterministic inverse for air-sampled NEE. The flat-interface seed selects a
// branch when curvature admits multiple connections. Unconverged samples are
// rejected without renormalizing the remaining sun samples. A material-sampled
// direction can still reach another branch; its NEE PDF must then be zero.
GraphicsWaterSunConnection GraphicsSampleWaterSun(ByteAddressBuffer field, float3 camera,
    float renderer, float3 receiver, float3 air_direction) {
  GraphicsWaterSunConnection result = (GraphicsWaterSunConnection)0;
  GraphicsWaterSunMapping seed = GraphicsMapWaterSun(air_direction,float3(0,0,1),false);
  if (!seed.valid) return result;
  float3 target = seed.air, water = seed.water;
  [loop] for (uint iteration=0u;iteration<8u;++iteration) {
    result = GraphicsEvaluateWaterSun(field,camera,renderer,receiver,water);
    if (!result.valid) return result;
    float3 residual = target-result.mapping.air;
    if (dot(residual,residual)<=1.e-12f) {
      // This NEE strategy constructs one exit followed by an air leg. A later
      // wave entry belongs to a different specular path, sampled by material
      // traversal instead; accepting it here would ignore its extra interfaces.
      if(GraphicsFindWaterSurfaceCrossing(field,camera,renderer,
          result.surface.position+result.mapping.air*.001f,result.mapping.air,false).valid)result.valid=false;
      return result;
    }
    float a = dot(result.air_tangent,result.air_tangent);
    float b = dot(result.air_tangent,result.air_bitangent);
    float c = dot(result.air_bitangent,result.air_bitangent);
    float determinant = a*c-b*b;
    if (!isfinite(determinant) || determinant<=1.e-12f) break;
    float2 rhs = float2(dot(result.air_tangent,residual),dot(result.air_bitangent,residual));
    float2 step = float2(c*rhs.x-b*rhs.y,a*rhs.y-b*rhs.x)/determinant;
    step *= min(1.f,.25f/max(length(step),1.e-12f));
    water = normalize(water+result.water_tangent*step.x+result.water_bitangent*step.y);
  }
  result.valid = false;
  return result;
}

// Same branch selection as NEE, with zero density for a valid connection that
// NEE cannot sample. This keeps MIS meaningful at folds instead of counting a
// local Jacobian as the density of every possible specular connection.
float GraphicsWaterSunNeePdfScale(ByteAddressBuffer field, float3 camera, float renderer,
    float3 receiver, GraphicsWaterSunConnection connection) {
  if (!connection.valid) return 0.f;
  GraphicsWaterSunConnection selected = GraphicsSampleWaterSun(field,camera,renderer,receiver,connection.mapping.air);
  if (!selected.valid || distance(selected.mapping.water,connection.mapping.water)>2.e-5f
      || abs(selected.surface.distance-connection.surface.distance)>1.e-3f) return 0.f;
  return 1.f/connection.mapping.solid_angle;
}
#endif
