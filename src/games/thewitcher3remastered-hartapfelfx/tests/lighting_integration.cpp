/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#define WITCHER_COEXISTENCE_HOST_ONLY
#include "../night/tests/coexistence.cpp"

#define DllMain HartapfelDllMain
#include "../addon.cpp"
#undef DllMain

int main() {
  using namespace renodx::utils::settings;
  constexpr auto target = "thewitcher3remastered-hartapfelfx-preset2";
  constexpr auto legacy_night = "renodx-darkernights-remastered-preset2";
  constexpr auto legacy_fill = "renodx-witcher3remastered-graphics-preset2";
  configuration[{"thewitcher3remastered-hartapfelfx", "SelectedPreset"}] = "2";
  configuration[{target, "NightFogStrength"}] = "14";
  constexpr auto preset_one = "thewitcher3remastered-hartapfelfx-preset1";
  constexpr auto preset_three = "thewitcher3remastered-hartapfelfx-preset3";
  configuration[{preset_one, "CloudShadowsV2"}] = "1";
  configuration[{target, "CloudShadowsV2"}] = "0";
  configuration[{preset_three, "CloudShadowsV2"}] = "1";
  configuration[{preset_three, "CloudShadowStrengthV1"}] = "35";
  configuration[{legacy_night, "NightFogStrength"}] = "5";
  configuration[{legacy_night, "NightVisibleSkyStrength"}] = "25";
  configuration[{legacy_fill, "GameplayLightStrength"}] = "0.35";
  configuration[{legacy_fill, "CutsceneLightStrength"}] = "0.43";
  const auto module = GetModuleHandleW(nullptr);
  if (!HartapfelDllMain(module, DLL_PROCESS_ATTACH, nullptr)) return 1;
  if (preset_index != 2 || nights::fog_strength != 14.f || nights::sky_haze_strength != 25.f
      || gameplay_strength != .35f || cutscene_strength != .43f) return 2;
  float migrated_strength = 0.f;
  if (clouds::shadows != 0.f
      || !reshade::get_config_value(nullptr, preset_one, "CloudShadowStrengthV1", migrated_strength)
      || migrated_strength != 100.f
      || !reshade::get_config_value(nullptr, preset_three, "CloudShadowStrengthV1", migrated_strength)
      || migrated_strength != 35.f) return 50;
  UpdateSetting("CloudShadowStrengthV1",25.f);
  if (clouds::shadows != .25f) return 51;
  // Follow the user's current authored default, then explicitly select Custom.
  // Named choices must not rewrite manual controls or appearance settings.
  if(clouds::quality_preset!=FindSetting("CloudQualityPresetV1")->default_value) return 11;
  UpdateSetting("CloudQualityPresetV1",0.f);
  UpdateSetting("CloudQualityV2",1.f);UpdateSetting("CloudStepSizeV2",50.f);
  const auto sampling=clouds::Quality(clouds::quality);
  const auto authoring=clouds::Authoring();
  const auto appearance=clouds::Appearance();
  for(unsigned choice=1;choice<=4;++choice) {
    UpdateSetting("CloudQualityPresetV1",float(choice));
    if(FindSetting("CloudQualityV2")->is_visible() ||FindSetting("CloudStepSizeV2")->is_visible()
        ||clouds::Authoring()!=authoring ||clouds::Appearance()!=appearance
        ||clouds::quality!=1.f ||clouds::step_size!=.5f) return 12;
    if(choice==3u &&clouds::Quality(clouds::quality)!=sampling) return 13;
  }
  UpdateSetting("CloudQualityPresetV1",0.f);
  if(clouds::Quality(clouds::quality)!=sampling) return 14;
  if(!FindSetting("CloudClearLowSunV1") ||clouds::clear_low_sun!=1.f)return 25;
  const auto* evening=FindSetting("EveningSunlightColourV1");
  if(!evening||evening->section!="Sun & Moon Appearance")return 44;
  const float evening_default = evening->default_value * .01f;
  if(hartapfelfx::sky::evening_sunlight!=evening_default)return 44;
  UpdateSetting("EveningSunlightColourV1",25.f);
  if(hartapfelfx::sky::evening_sunlight!=.25f)return 45;
  UpdateSetting("EveningSunlightColourV1",100.f);
  if(hartapfelfx::sky::evening_sunlight!=1.f)return 46;
  UpdateSetting("CloudClearLowSunV1",0.f);
  if(clouds::QualityLighting(clouds::quality)[2]!=0.f)return 26;

  const auto* player = FindSetting("PlayerLighting");
  const auto* cloud = FindSetting("CloudModeV2");
  const auto* sky_haze = FindSetting("NightSkyHazeStrength");
  const auto* stars=FindSetting("NightStarBrightness");
  const auto* sun_glow=FindSetting("SunGlowSizeV1");
  if(!sun_glow||sun_glow->section!="Sun & Moon Appearance"||sun_glow->default_value!=125.f
      ||hartapfelfx::sky::sun_glow_size!=1.25f)return 30;
  UpdateSetting("SunGlowSizeV1",200.f);
  if(hartapfelfx::sky::sun_glow_size!=2.f)return 31;
  if(!stars||stars->section!="Night Atmosphere")return 27;
  const float star_default = stars->default_value * .01f;
  if(hartapfelfx::sky::star_brightness!=star_default)return 27;
  UpdateSetting("NightStarBrightness",240.f);
  if(std::abs(hartapfelfx::sky::star_brightness-2.4f)>.0001f)return 28;
  if (!player || !cloud || !sky_haze || player->section != "Character Lighting") return 3;
  hartapfelfx::ui::selected=hartapfelfx::ui::Tab::Lighting;
  if (!player->is_visible() || cloud->is_visible() || sky_haze->is_visible()) return 4;
  hartapfelfx::ui::selected=hartapfelfx::ui::Tab::Clouds;
  if (player->is_visible() || !cloud->is_visible() || sky_haze->is_visible()) return 4;
  if(!FindSetting("CloudQualityV2")->is_visible() ||!FindSetting("CloudStepSizeV2")->is_visible()
      ||FindSetting("CloudQualityV2")->section!="Cloud Quality (Advanced)")return 15;
  hartapfelfx::ui::selected=hartapfelfx::ui::Tab::Nights;
  if (player->is_visible() || cloud->is_visible() || !sky_haze->is_visible()||!stars->is_visible()) return 5;
  UpdateSetting("CloudQualityPresetV1",2.f);
  UpdateSetting("CloudModeV2", 0.f);
  hartapfelfx::ui::ResetTab(*renodx::utils::settings::settings,hartapfelfx::ui::Tab::Nights);
  if(hartapfelfx::sky::star_brightness!=star_default||hartapfelfx::sky::sun_glow_size!=2.f)return 29;
  if (clouds::mode != 0.f || gameplay_strength != .35f || nights::sky_haze_strength != 15.f
      ||clouds::quality_preset!=2.f) return 6;
  const auto fog_amount=FindSetting("FogAmountV1");
  const auto fog_quality=FindSetting("FogQualityPresetV1");
  if(!fog_amount ||!fog_quality ||injection.quality_preset!=1.f ||injection.haze_reduction!=0.f)return 17;
  const auto fog_before=injection;
  UpdateSetting("FogAmountV1",0.f);
  if(injection.haze_reduction!=1.f ||injection.sunlight!=fog_before.sunlight
      ||injection.density!=fog_before.density ||injection.local_strength!=fog_before.local_strength)return 18;
  for(unsigned quality=1;quality<=5;++quality) {
    UpdateSetting("FogQualityPresetV1",float(quality));
    const auto grid=hartapfelfx::fog::GridQuality(injection,1920,1080);
    if(FindSetting("FogQuality")->is_visible() ||grid[0]<120u ||grid[2]<64u
        ||injection.quality!=fog_before.quality)return 19;
  }
  const auto portrait=hartapfelfx::fog::GridQuality(injection,1080,1920);
  if(uint64_t(portrait[0])*portrait[1]>256u*144u)return 23;
  if(FindSetting("FogClearBeams") ||FindSetting("FogDefaultBalance"))return 21;
  if(FindSetting("FogStart")->min!=-100.f)return 22;
  UpdateSetting("FogStart",-50.f);
  if(injection.start_distance!=-50.f)return 24;
  hartapfelfx::ui::ResetTab(*renodx::utils::settings::settings,hartapfelfx::ui::Tab::Fog);
  if(std::memcmp(&injection,&fog_before,sizeof(injection))!=0 ||clouds::clear_low_sun!=0.f
      ||clouds::quality_preset!=2.f ||gameplay_strength!=.35f)return 20;
  hartapfelfx::ui::ResetTab(*renodx::utils::settings::settings,hartapfelfx::ui::Tab::Clouds);
  if(clouds::quality_preset!=FindSetting("CloudQualityPresetV1")->default_value ||clouds::quality!=1.f ||clouds::step_size!=.5f
      ||clouds::clear_low_sun!=1.f ||clouds::QualityLighting(clouds::quality)[2]!=1.f ||clouds::shadows!=1.f
      ||gameplay_strength!=.35f)return 16;

  // Exercise the actual composed hook against fresh common constants. The
  // environment matching scalar and the night fog color must coexist.
  fill_native::layout.common = nights::detected_layout.common = 1;
  nights::night_schedule.store(nights::NightSchedule());
  nights::fog_multiplier.store(.5f);
  nights::build_common_constants = [](const void*, void* output) {
    auto* frame = static_cast<float*>(output);
    frame[71 * 4] = .25f;
    frame[10 * 4] = 1.f; // matrix-row sentinel; never a lighting colour
    frame[39 * 4] = .8f;
    frame[39 * 4 + 3] = .6f;
  };
  std::array<unsigned char, 0x15c4> environment{};
  const void* input[2] = {nullptr, environment.data()};
  std::array<float, 341 * 4> frame{};
  player_fill::Publish(true, true, .2f, .2f);
  nights::CommonConstantsHook(input, frame.data());
  if (frame[71 * 4] != 1.f || frame[39 * 4] != .4f || frame[39 * 4 + 3] != .6f) return 7;
  float sky_impact = 1.f;
  nights::sky_impact.Initialize(&sky_impact);
  nights::installed = nights::attempted = true;
  {
    namespace emission=hartapfelfx::sky::emission;
    emission::enabled=true;
    const float native_light[3]={3,2,1},native_moon[3]={.1f,.2f,.4f};
    emission::ObservePrimary(native_light);emission::ObserveMoon(native_moon,false);
    std::array<float,341*4> palette{};
    palette[199*4]=10;palette[199*4+1]=1;palette[199*4+2]=.1f;
    palette[204*4+2]=.9987492f;palette[204*4+3]=.05f;
    emission::ObserveFrame(palette.data());
    std::array<float,4> surface{4,6,2,.37f};
    const float luminance=4*.2126f+6*.7152f+2*.0722f;
    emission::Apply(surface.data());
    if(std::abs(surface[0]/surface[1]-10.f)>.001f||surface[3]!=.37f
        ||std::abs(surface[0]*.2126f+surface[1]*.7152f+surface[2]*.0722f-luminance)>.0001f)return 33;
    const auto first=surface;emission::Apply(surface.data());
    for(unsigned i=0;i<4;++i)if(std::abs(first[i]-surface[i])>.0001f)return 34;
    // World-light endpoints/interpolation preserve energy; cloud/source cache
    // remains fully coloured independently of this user blend.
    emission::ObserveTime(19.f/24.f);emission::ObserveFrame(palette.data());
    const auto cloud_colour=emission::sun.load();
    for(float blend:{0.f,.25f,.5f,1.f}) {
      emission::evening_blend=blend;surface={4,6,2,.37f};emission::Apply(surface.data());
      for(unsigned i=0;i<3;++i)
        if(std::abs(surface[i]-std::lerp(std::array<float,3>{4,6,2}[i],first[i],blend))>.0001f)return 47;
      if(std::abs(surface[0]*.2126f+surface[1]*.7152f+surface[2]*.0722f-luminance)>.0001f
          ||surface[3]!=.37f||emission::sun.load()!=cloud_colour)return 48;
    }
    emission::evening_blend=0.f;
    emission::ObserveTime(5.f/24.f);emission::ObserveFrame(palette.data());
    surface={4,6,2,.37f};emission::Apply(surface.data());
    for(unsigned i=0;i<3;++i)if(std::abs(surface[i]-first[i])>.0001f)return 49;
    emission::evening_blend=1.f;emission::daytime=-1.f;
    palette[204*4+3]=-.5f;palette[204*4+2]=.8660254f;
    emission::ObserveFrame(palette.data());surface={4,6,2,.37f};emission::Apply(surface.data());
    if(std::abs(surface[2]/surface[0]-4.f)>.001f)return 35;
    // Exercise the actual three engine hook paths, not only the colour math.
    const auto old_global=nights::build_global_constants;
    const auto old_direct=nights::build_direct_constants;
    const auto old_environment=nights::build_environment;
    nights::build_global_constants=[](const void*,void* output) {
      auto* values=static_cast<float*>(output);values[40]=4;values[41]=6;values[42]=2;values[43]=.37f;
    };
    std::array<float,64> global{};const void* global_context[]={environment.data()};
    nights::GlobalConstantsHook(global_context,global.data());
    if(std::abs(global[42]/global[40]-4.f)>.001f||global[43]!=.37f)return 39;
    std::array<float,256> direct{};
    std::vector<unsigned char> renderer(nights::direct_constants_offset+sizeof(void*));
    auto* direct_pointer=reinterpret_cast<unsigned char*>(direct.data());
    std::memcpy(renderer.data()+nights::direct_constants_offset,&direct_pointer,sizeof(direct_pointer));
    nights::build_direct_constants=[](void* renderer,const void*) {
      float* values=nullptr;std::memcpy(&values,static_cast<unsigned char*>(renderer)+nights::direct_constants_offset,sizeof(values));
      for(unsigned row:{1u,61u,62u}){values[row*4]=4;values[row*4+1]=6;values[row*4+2]=2;values[row*4+3]=.37f;}
    };
    nights::DirectConstantsHook(renderer.data(),environment.data());
    for(unsigned row:{1u,61u,62u})if(std::abs(direct[row*4+2]/direct[row*4]-4.f)>.001f||direct[row*4+3]!=.37f)return 40;
    nights::build_environment=[](void* output,const void*) {
      auto* values=static_cast<float*>(output);
      for(unsigned offset:{0x280u,0x290u,0x2a0u}){values[offset/4]=4;values[offset/4+1]=6;values[offset/4+2]=2;values[offset/4+3]=.37f;}
    };
    std::array<float,176> view{};const void* view_context[]={nullptr,nullptr,environment.data()};
    nights::BuildHook(view.data(),view_context);
    for(unsigned offset:{0x280u,0x290u,0x2a0u})if(std::abs(view[offset/4+2]/view[offset/4]-4.f)>.001f||view[offset/4+3]!=.37f)return 41;
    frame.fill(0);nights::CommonConstantsHook(input,frame.data());
    if(frame[10*4]!=1.f)return 42;
    nights::build_global_constants=old_global;nights::build_direct_constants=old_direct;nights::build_environment=old_environment;
    emission::enabled=false;surface={4,6,2,.37f};emission::Apply(surface.data());
    if(surface!=std::array<float,4>{4,6,2,.37f})return 36;
    std::array<float,40> geometry{};geometry[0]=geometry[5]=geometry[10]=1;geometry[11]=1000;
    geometry[32]=geometry[33]=geometry[34]=20;geometry[36]=geometry[37]=geometry[38]=-10;
    const float lunar_radius=hartapfelfx::sky::NativeRadius(geometry,{0,0,0},false);
    const float solar_radius=hartapfelfx::sky::NativeRadius(geometry,{0,0,0},true);
    if(std::abs(lunar_radius-std::asin(.01f))>.000001f||std::abs(solar_radius-std::asin(std::sqrt(.75f)*.01f))>.000001f)return 37;
    geometry[11]=2000;
    if(std::abs(hartapfelfx::sky::NativeRadius(geometry,{0,0,0},false)-std::asin(.005f))>.000001f)return 38;
    std::puts("PASS coherent solar/lunar colour, luminance/alpha/Off preservation, no feedback, native projected mesh sizes");
  }
  hartapfelfx::ui::ResetTab(*renodx::utils::settings::settings,hartapfelfx::ui::Tab::Lighting);
  if(hartapfelfx::sky::sun_glow_size!=1.25f||hartapfelfx::sky::evening_sunlight!=evening_default)return 32;
  OnPresetOff();
  if (player_fill::GetControls().enabled || nights::lighting_enabled != 0.f
      || injection.enabled != 0.f || clouds::mode != 0.f) return 8;
  nights::CommonConstantsHook(input, frame.data());
  if (frame[71 * 4] != .25f || frame[39 * 4] != .8f) return 9;
  if (!HartapfelDllMain(module, DLL_PROCESS_DETACH, nullptr) || invalid_registrations || !callbacks.empty()) return 10;
  std::puts("PASS: tab routing, standalone profiles, isolated night reset, shared constants and preset Off");
}
