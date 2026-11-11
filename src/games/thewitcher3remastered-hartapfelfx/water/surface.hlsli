// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#include "caustics.hlsli"
#include "../lighting/graphics/lighting/brdf.hlsli"

struct WaterHit {
  float2 uv;
  float3 world;
  float depth;
  float confidence;
};

float3 WaterOpticalNormal(float2 world, float3 coarse, float3 native, float interaction, float wave_strength) {
  const float footprint = max(length(ddx_coarse(world)), length(ddy_coarse(world)));
  const float detail = 1.f - smoothstep(.04f, .36f, footprint);
  const float3 normal = lerp(float3(0.f, 0.f, 1.f), lerp(coarse, native, .34f * detail), .55f);
  const float2 slope = ResolvedWaterSlope(world, GlobalShaderConsts_000.x, footprint);
  const float3 optical = normal + float3(-slope * (.25f + .30f * saturate(wave_strength)), 0.f);
  // Native already contains the local simulation normal. Retain it in the
  // wake instead of applying the ambient-wave filter to the disturbance.
  return normalize(lerp(optical, native, .78f * interaction));
}

float3 WaterInterfaceNormal(float3 normal, float interaction) {
  return normalize(lerp(float3(0.f, 0.f, 1.f), normal, lerp(.55f, .92f, interaction)));
}

WaterHit ReadWaterHit(float2 uv, float3 camera, float3 camera_forward) {
  WaterHit hit = {uv, float3(0.f, 0.f, 0.f), -1.f, 0.f};
  const float2 margin = .5f * GlobalShaderConsts_016.zw;
  const float2 focal = float2(receiver_frame[13].x, receiver_frame[14].y);
  if (any(uv < margin) || any(uv > 1.f - margin) || any(abs(focal) < 1e-5f)) return hit;
  const float raw_depth = t15.SampleLevel(s15, uv, 0.f).x;
  const float divisor = (raw_depth * cb12_022x + cb12_022y) * cb12_021x + cb12_021y;
  if (!isfinite(divisor) || divisor < 0.f) return hit;
  hit.depth = rcp(max(divisor, .005f));
  const float2 ndc = uv * float2(2.f, -2.f) + float2(-1.f, 1.f);
  const float2 view = (ndc - receiver_frame[15].xy) / focal;
  const float3 right = float3(receiver_frame[1].x, receiver_frame[2].x, receiver_frame[3].x);
  const float3 up = float3(receiver_frame[1].y, receiver_frame[2].y, receiver_frame[3].y);
  hit.world = camera + hit.depth * (view.x * right + view.y * up + camera_forward);
  const float2 edge = min(uv, 1.f - uv);
  hit.confidence = smoothstep(0.f, .025f, min(edge.x, edge.y));
  return hit;
}

WaterHit ProbeWaterRay(float2 uv, float3 position, float3 camera, float3 direction,
                       float distance, float3 camera_forward, float shift_limit) {
  const float3 right = float3(receiver_frame[1].x, receiver_frame[2].x, receiver_frame[3].x);
  const float3 up = float3(receiver_frame[1].y, receiver_frame[2].y, receiver_frame[3].y);
  const float3 projection = position - camera;
  const float3 target = distance >= 200.f ? direction : projection + direction * distance;
  const float target_depth = dot(target, camera_forward);
  if (target_depth <= .03f) {
    const WaterHit miss = {uv, float3(0.f, 0.f, 0.f), -1.f, 0.f};
    return miss;
  }
  const float3 delta = target / target_depth - projection / dot(projection, camera_forward);
  const float2 focal = float2(receiver_frame[13].x, receiver_frame[14].y);
  const float2 shift = float2(dot(delta, right), -dot(delta, up)) * focal * .5f;
  // The optional limit is for the short, shallow-water entry probe.
  uv += shift_limit > 0.f ? shift * rsqrt(1.f + dot(shift, shift) / (shift_limit * shift_limit)) : shift;
  WaterHit hit = ReadWaterHit(uv, camera, camera_forward);
  hit.confidence *= smoothstep(.03f, .25f, target_depth);
  return hit;
}

float ExteriorHitConfidence(WaterHit hit, float3 surface, float surface_depth) {
  const float air_side = hit.depth >= 199.f ? 1.f : smoothstep(-.03f, .12f, hit.world.z - surface.z);
  return hit.confidence * air_side * smoothstep(0.f, .15f, hit.depth - surface_depth);
}

float3 ApplyNativeWaterMurk(float3 body, float eye_depth_gap, float3 incident, float3 camera_forward) {
  const float3 tint = GlobalShaderConsts_208.yzw;
  const float3 ambient = WaterMediumRadiance(GlobalShaderConsts_176.rgb, tint, GlobalShaderConsts_224.x);
  const float refracted_z = refract(incident, float3(0.f, 0.f, 1.f), rcp(WaterIor)).z;
  const float distance = WaterColumnLength(min(eye_depth_gap, 200.f), incident, camera_forward, refracted_z);
  return lerp(ambient, body, WaterTransmittance(distance, WaterMediumDensity(fx.water_murk, GlobalShaderConsts_224.y), tint));
}

float3 RenderWaterSurface(float2 uv, float2 wave_uv, float3 world, float surface_depth, float eye_depth_gap,
                          float3 incident, float3 normal, float3 camera_forward, float interaction, float exclusion,
                          float foam, float illumination, float roughness) {
  const float3 camera = float3(cb1_036x, cb1_036y, cb1_036z);
  const float3 up = float3(0.f, 0.f, 1.f);
  const float3 tint = GlobalShaderConsts_208.yzw;
  const float3 shallow_tint = GlobalShaderConsts_176.rgb;
  const float density = WaterMediumDensity(fx.water_murk, GlobalShaderConsts_224.y);
  const float3 ambient = WaterMediumRadiance(shallow_tint, tint, GlobalShaderConsts_224.x);
  if (camera.z < world.z) {
    // The game camera uses a broad exterior view at grazing angles. Carry its
    // wave displacement onto the pre-water image, guarded by the opaque depth.
    // A missing directional ray must never replace that image with water tint.
    const float3 ripple = normal - up;
    const float2 screen_slope = float2(dot(ripple, float3(receiver_frame[1].x, receiver_frame[2].x, receiver_frame[3].x)),
                                       -dot(ripple, float3(receiver_frame[1].y, receiver_frame[2].y, receiver_frame[3].y)));
    const WaterHit wave_hit = ReadWaterHit(wave_uv + screen_slope * .009f, camera, camera_forward);
    const float wave_confidence = ExteriorHitConfidence(wave_hit, world, surface_depth) * (1.f - exclusion);
    float2 exterior_uv = lerp(uv, wave_hit.uv, wave_confidence);
    // Use broad slopes for the Snell window and retain more detail for the
    // direction of the transmitted and reflected rays within it.
    const float window_cosine = saturate(dot(normalize(lerp(up, normal, .30f)), incident));
    const float fresnel = WaterExitFresnel(window_cosine, max(.09f, .32f * roughness));
    const float3 medium_normal = -normalize(lerp(up, normal, lerp(.60f, .82f, interaction)));
    // Open the full angular map as the camera aims up. A per-pixel crossfade
    // between two images otherwise paints a second shoreline across the sky.
    const float angular_view = smoothstep(.42f, .70f, camera_forward.z);
    float directional_weight = 0.f;
    if (angular_view > 0.f && fresnel < .999f && exclusion < 1.f) {
      const float view_cosine = saturate(dot(medium_normal, -incident));
      const float exit_cosine = max(WaterExitCosine(view_cosine, .09f), WaterCriticalCosine + .0001f);
      const float3 tangent = incident + view_cosine * medium_normal;
      const float3 exit_incident = tangent * sqrt(max(1.f - exit_cosine * exit_cosine, 0.f) / max(dot(tangent, tangent), 1e-8f))
                                 - exit_cosine * medium_normal;
      const float3 refracted = refract(exit_incident, medium_normal, WaterIor);
      const float forward = dot(refracted, camera_forward);
      if (forward > .03f) {
        const bool sky = surface_depth + eye_depth_gap >= 199.f;
        const float travel = sky ? 200.f : min(200.f, eye_depth_gap / forward);
        WaterHit hit = ProbeWaterRay(uv, world, camera, refracted, travel, camera_forward, 0.f);
        // Reproject once at the sampled object's depth so nearby dock and
        // bank silhouettes follow the transmitted ray as well as the sky.
        const float gap = hit.depth - surface_depth;
        if (gap > .05f && hit.depth < 199.f) {
          const WaterHit refined = ProbeWaterRay(uv, world, camera, refracted, min(199.f, gap / forward), camera_forward, 0.f);
          if (refined.depth > surface_depth && refined.world.z >= world.z - .03f
              && abs(refined.depth - hit.depth) < max(.35f, .20f * hit.depth)) hit = refined;
        }
        directional_weight = ExteriorHitConfidence(hit, world, surface_depth)
                           * smoothstep(.52f, .88f, window_cosine) * angular_view * (1.f - exclusion);
        if (directional_weight > 0.f) {
          const float2 projected_uv = lerp(exterior_uv, hit.uv, directional_weight);
          const float projected_confidence = ExteriorHitConfidence(ReadWaterHit(projected_uv, camera, camera_forward),
                                                                  world, surface_depth);
          exterior_uv = lerp(exterior_uv, projected_uv, projected_confidence);
          directional_weight *= projected_confidence;
        }
      }
    }

    // Keep the horizon legible with a subdued reflected image. Fresnel takes
    // over as a directional exit ray becomes reliable nearer the normal.
    const float exterior = smoothstep(0.f, .15f, eye_depth_gap);
    const float broad_reflection = lerp(1.f, lerp(.36f, .12f, window_cosine), exterior);
    const float reflection_weight = lerp(broad_reflection, fresnel, directional_weight);
    const float3 reflected_ambient = WaterReflectionAmbient(shallow_tint, tint * clamp(GlobalShaderConsts_224.x, 0.f, 10.f), illumination);
    float3 reflection = reflected_ambient;
    const float3 reflected = reflect(incident, medium_normal);
    // Search a few depths for visible submerged terrain along the reflected ray.
    if (reflection_weight > .025f && reflected.z < -.025f && dot(reflected, camera_forward) > .08f) {
      float best = 0.f;
      static const float steps[3] = {1.5f, 4.f, 10.f};
      [loop] for (uint i = 0; i < 3; ++i) {
        const WaterHit hit = ProbeWaterRay(uv, world, camera, reflected, steps[i], camera_forward, 0.f);
        const float3 segment = hit.world - world;
        const float along = dot(segment, reflected);
        if (hit.depth > .03f && hit.depth < 199.f && segment.z < -.03f && along > .1f && along < 16.f) {
          const float error = length(segment - along * reflected);
          const float confidence = hit.confidence * (1.f - smoothstep(.04f, max(.3f, .10f * along), error))
                                 * smoothstep(.1f, .35f, along) * (1.f - smoothstep(12.f, 16.f, along))
                                 * smoothstep(.03f, .15f, -segment.z);
          if (confidence > best) {
            best = confidence;
            const float3 lit_receiver = t6.SampleLevel(s6, hit.uv, 0.f).rgb;
            reflection = lerp(reflected_ambient, lerp(ambient, lit_receiver, WaterTransmittance(along, density, tint)), confidence);
          }
        }
      }
    }
    return lerp(t6.SampleLevel(s6, exterior_uv, 0.f).rgb, reflection, reflection_weight);
  }

  // Use the registered colour/depth pair as the reference. In thin water
  // there is too little optical path for ripples to displace a dark receiver.
  float3 background = t6.SampleLevel(s6, uv, 0.f).rgb;
  const float3 interface_normal = WaterInterfaceNormal(normal, interaction);
  const float view_cosine = saturate(dot(interface_normal, -incident));
  const float3 refracted = refract(incident, interface_normal, rcp(WaterIor));
  const float3 receiver = world + incident * (min(eye_depth_gap, 200.f) / max(dot(incident, camera_forward), .125f));
  const float floor_depth = max(world.z - receiver.z, 0.f);
  // The aligned depth defines the fallback path. A steep wake can steer a
  // sampled ray, while a rejected sample keeps a stable reference column.
  const float reference_z = lerp(refracted.z, refract(incident, up, rcp(WaterIor)).z, interaction);
  const float base_distance = WaterColumnLength(min(eye_depth_gap, 200.f), incident, camera_forward, reference_z);
  float3 warped_background = background;
  float warped_distance = base_distance;
  float3 warped_receiver = receiver;
  float refraction_weight = 0.f;
  const float forward = dot(refracted, camera_forward);
  const float thin_water = max(smoothstep(.10f, .75f, floor_depth), interaction * smoothstep(.025f, .25f, floor_depth));
  if (thin_water > 0.f && forward > .08f && exclusion < 1.f && surface_depth + eye_depth_gap < 199.f) {
    const WaterHit hit = ProbeWaterRay(uv, world, camera, refracted, min(40.f, base_distance), camera_forward,
                                      .026f * max(.1f, thin_water * (1.f - exclusion)));
    const float gap = hit.depth - surface_depth;
    const float consistency = 1.f - smoothstep(.06f, max(.22f, .26f * eye_depth_gap), abs(gap - eye_depth_gap));
    refraction_weight = hit.confidence * thin_water * (1.f - exclusion) * consistency
                      * smoothstep(.025f, .16f, world.z - hit.world.z) * smoothstep(0.f, .15f, gap);
    if (refraction_weight > 0.f) {
      warped_background = t6.SampleLevel(s6, hit.uv, 0.f).rgb;
      warped_receiver = hit.world;
      warped_distance = length(hit.world - world);
    }
  }
  const float3 light = normalize(GlobalShaderConsts_144.xyz);
  const float3 light_rgb = max(cb13_raw[1].xyz, 0.f);
  float3 glint = 0.f;
  if (light.z > 0.f && illumination > .001f) {
    const float3 half_vector = normalize(light - incident);
    const float no_l = saturate(dot(normal, light));
    const float lobe = GraphicsDirectGGX(dot(normal, half_vector), saturate(dot(normal, -incident)), no_l, roughness)
                     * no_l * WaterFresnel(dot(-incident, half_vector), WaterIor);
    glint = light_rgb * illumination * min(lobe, 1.25f);
    if (surface_depth + eye_depth_gap < 199.f && exclusion < .99f) {
      const float3 caustic_receiver = lerp(receiver, warped_receiver, refraction_weight);
      const float depth = world.z - caustic_receiver.z;
      const float3 focus = WaterCaustics(caustic_receiver.xy, depth, length(world - camera), light, GlobalShaderConsts_000.x);
      const float3 irradiance = light_rgb / (1.f + max(light_rgb.r, max(light_rgb.g, light_rgb.b)));
      const float3 caustic = 1.f + 1.55f * illumination * focus * irradiance
                           * WaterTransmittance(depth / max(light.z, .25f), density, tint);
      background *= caustic;
      warped_background *= caustic;
    }
  }
  float3 body = lerp(ambient, background, WaterTransmittance(base_distance, density, tint));
  if (refraction_weight > 0.f) {
    body = lerp(body, lerp(ambient, warped_background, WaterTransmittance(warped_distance, density, tint)), refraction_weight);
  }
  return ShadeWaterSurface(body, view_cosine, shallow_tint, illumination, glint, foam);
}
