// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#ifndef WITCHER_GRAPHICS_WATER_LOCAL_CONNECTION
#define WITCHER_GRAPHICS_WATER_LOCAL_CONNECTION
#include "sun_connection.hlsli"

struct GraphicsWaterLocalConnection {
  GraphicsWaterSunConnection exit;
  float air_distance;
  float area_per_solid_angle; // Emitter plane normal to its ray: dA / d omega_receiver.
  float3 weight;             // Multiplies native inverse-square light energy.
  float3 receiver_direction;
  float3 emitter_direction;
  float receiver_distance;
  float emitter_distance;
  bool valid;
};

// Connect a submerged receiver to a finite air emitter. The native light's
// center and its jittered shadow endpoint must be connected separately: its
// disk sampling is an artistic shadow model, not an area-emitter PDF.
// This strategy covers one transmitted exit; unknown geometry, extra crossings
// and unconverged branches are rejected, never extended as an infinite sun ray.
GraphicsWaterLocalConnection GraphicsConnectWaterLocal(ByteAddressBuffer field,
    float3 camera,float renderer,float3 receiver,float3 emitter) {
  GraphicsWaterLocalConnection result=(GraphicsWaterLocalConnection)0;
  float3 straight=emitter-receiver;
  float distance_squared=dot(straight,straight);
  if(any(!isfinite(emitter)) || !isfinite(distance_squared) || distance_squared<=1.e-8f)return result;
  GraphicsWaterSunMapping seed=GraphicsMapWaterSun(straight,float3(0,0,1),false);
  if(!seed.valid)return result;
  float3 water=seed.water;
  [loop] for(uint iteration=0u;iteration<16u;++iteration) {
    result.exit=GraphicsEvaluateWaterSun(field,camera,renderer,receiver,water);
    if(!result.exit.valid)return result;
    // Keep the solve relative to the receiver. World-space exits lose a
    // millimetre at large map coordinates, enough to stall near-water lights.
    float3 to_light=straight-water*result.exit.surface.distance;
    result.air_distance=length(to_light);
    if(!isfinite(result.air_distance) || result.air_distance<=.001f)return result;
    float3 target=to_light/result.air_distance;
    if(dot(target,result.exit.surface.normal)<=0.f)return result;
    float3 air=result.exit.mapping.air,normal=result.exit.surface.normal;
    float3 derivative[2];
    [unroll] for(uint axis=0u;axis<2u;++axis) {
      float3 tangent=axis==0u?result.exit.water_tangent:result.exit.water_bitangent;
      float3 position_derivative=result.exit.surface.distance*(tangent-water*dot(normal,tangent)/dot(normal,water));
      // Differentiate air direction minus normalized(endpoint - exit). This
      // includes both the moving normal and the finite emitter's parallax.
      derivative[axis]=(axis==0u?result.exit.air_tangent:result.exit.air_bitangent)
          +(position_derivative-target*dot(target,position_derivative))/result.air_distance;
    }
    float3 residual=target-air;
    // Snell's square root loses angular precision near the critical angle.
    // Bound both angle and endpoint error rather than demanding sub-ULP steps.
    float angular_tolerance=max(1.e-6f,1.e-7f/max(dot(air,normal),.01f));
    if(dot(residual,residual)<=min(angular_tolerance*angular_tolerance,1.e-8f/(result.air_distance*result.air_distance))) {
      // At convergence L^2 det(d direction difference) is the endpoint-plane
      // area Jacobian. The sun's angular Jacobian alone loses finite focusing.
      result.area_per_solid_angle=result.air_distance*result.air_distance
          *abs(dot(cross(derivative[0],derivative[1]),air));
      if(!isfinite(result.area_per_solid_angle) || result.area_per_solid_angle<=1.e-10f)return result;
      GraphicsWaterSurfaceCrossing next=GraphicsFindWaterSurfaceCrossing(field,camera,renderer,
          result.exit.surface.position+air*.001f,air,false,result.air_distance-.001f);
      if(next.valid && next.distance<=result.air_distance-.001f)return result;
      result.weight=result.exit.surface.transmission*result.exit.mapping.radiance
          *(distance_squared/result.area_per_solid_angle);
      result.receiver_direction=result.exit.mapping.water;
      result.emitter_direction=result.exit.mapping.air;
      result.receiver_distance=result.exit.surface.distance;
      result.emitter_distance=result.air_distance;
      result.valid=all(isfinite(result.weight));
      return result;
    }
    float a=dot(derivative[0],derivative[0]),b=dot(derivative[0],derivative[1]),c=dot(derivative[1],derivative[1]);
    float determinant=a*c-b*b;
    if(!isfinite(determinant) || determinant<=1.e-12f)break;
    float2 rhs=float2(dot(derivative[0],residual),dot(derivative[1],residual));
    float2 step=float2(c*rhs.x-b*rhs.y,a*rhs.y-b*rhs.x)/determinant;
    step*=min(1.f,.25f/max(length(step),1.e-12f));
    // Near-surface emitters can require a nearly critical exit. An unrestricted
    // Newton step crosses TIR even for a smooth flat surface; reduce the step
    // until it stays on a valid branch and actually improves the endpoint.
    bool improved=false;
    [loop] for(uint reduction=0u;reduction<10u;++reduction) {
      float3 candidate=normalize(water+result.exit.water_tangent*step.x+result.exit.water_bitangent*step.y);
      GraphicsWaterSunConnection trial=GraphicsEvaluateWaterSun(field,camera,renderer,receiver,candidate);
      if(trial.valid) {
        float3 trial_target=straight-candidate*trial.surface.distance;
        float trial_distance=length(trial_target);
        if(trial_distance>.001f && dot(trial_target,trial.surface.normal)>0.f) {
          float3 trial_residual=trial_target/trial_distance-trial.mapping.air;
          if(dot(trial_residual,trial_residual)<dot(residual,residual)) {
            water=candidate;improved=true;break;
          }
        }
      }
      step*=.5f;
    }
    if(!improved)break;
  }
  return result;
}

// Optical reciprocity supplies the same stationary path in reverse, including
// curved-surface focusing. Swapping a water receiver and air emitter divides
// dA/dOmega by n^2. The reverse radiance factor is T/n^2 instead of T*n^2;
// consequently the complete point-light weight is the forward weight / n^2.
// Retain the water-side geometric record for absorption and the interface point.
GraphicsWaterLocalConnection GraphicsConnectWaterLocalEntry(ByteAddressBuffer field,
    float3 camera,float renderer,float3 receiver,float3 emitter) {
  GraphicsWaterLocalConnection result=GraphicsConnectWaterLocal(field,camera,renderer,emitter,receiver);
  if(result.valid) {
    const float ior_squared=1.333f*1.333f;
    result.area_per_solid_angle/=ior_squared;
    result.weight/=ior_squared;
    result.receiver_direction=-result.exit.mapping.air;
    result.emitter_direction=-result.exit.mapping.water;
    result.receiver_distance=result.air_distance;
    result.emitter_distance=result.exit.surface.distance;
  }
  return result;
}
#endif
