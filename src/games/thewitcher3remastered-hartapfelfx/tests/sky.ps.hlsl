// Test adapter for the same radiance used by both native sky variants.
#include "../clouds/common.hlsli"
#define SKY_FRAME frame
#define SKY_DATA cloud_shared
#define SKY_CLOCK cloud_clock
#define SKY_NATIVE_RADIUS private_sky[7].xy
#define SKY_SUN_EMISSION emission_sun
#define SKY_MOON_EMISSION emission_moon
#include "../sky/celestial.hlsli"
float4 main(float4 position:SV_Position):SV_Target {
  float3 ray=CloudRay(position.xy/dimensions.zw),sun,moon;float mask;
  float footprint=max(length(ddx(ray)),length(ddy(ray)));
  float air=SkyFogTransmission(ray);
  SkyDiscs(ray,footprint,air,sun,moon,mask);
  return float4(SkyStars(ray,footprint,air,mask)
      +(frame[340].z==1.f?float3(.012f,.028f,.04f):0.f),1.f);
}
