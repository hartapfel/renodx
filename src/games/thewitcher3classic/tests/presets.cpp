/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#include "../addon.cpp"
#include <iostream>
#include <stdexcept>
#include <unordered_set>

int main(int argc,char** argv) {
  namespace ui=renodx::utils::settings;
  namespace preset=witcher3classic::presets;
  namespace night=witcher3classic::night;
  try {
    auto check=[](bool valid,const char* message){if(!valid)throw std::runtime_error(message);};
    ui::settings=&settings;
    ui::preset_index=0; // no config writes or game hooks in this executable
    if(argc>1 &&std::string_view(argv[1])=="--cloud-sampling") {
      namespace clouds=witcher3classic::clouds;
      for(const auto& [key,physical]:{std::pair{"GfxCloudDensity",.6f},std::pair{"GfxCloudDetail",4.f},
          std::pair{"GfxCloudDetailSize",.4f}}) {
        auto* setting=ui::FindSetting(key);
        check(setting &&setting->default_value==100.f &&std::abs(*setting->binding-physical)<1.e-6f
            &&std::abs(setting->parse(100.f)-physical)<1.e-6f,"Rebased cloud startup/UI units mismatch");
      }
      check(clouds::base_softness==0.f &&clouds::coverage==1.f &&clouds::size==1.f,"Approved appearance defaults mismatch");
      auto* resolution=ui::FindSetting("GfxCloudResolution");
      auto* steps=ui::FindSetting("GfxCloudStepSize");
      check(resolution &&steps &&resolution->section=="Clouds" &&steps->section=="Clouds"
          &&resolution->labels.size()==4 &&resolution->default_value==0.f &&steps->default_value==100.f
          &&clouds::resolution==0.f &&clouds::step_size==1.f
          &&!resolution->tooltip.empty() &&!steps->tooltip.empty(),"Cloud sampling menu/defaults mismatch");
      for(float quality:{0.f,1.f,2.f,3.f,4.f,5.f}) {
        clouds::resolution=0.f;clouds::step_size=1.f;
        const auto baseline=clouds::Quality(quality);
        for(unsigned selected:{1u,2u,3u})for(float percent:{50.f,100.f,200.f}) {
          resolution->Set(float(selected))->Write();steps->Set(percent)->Write();
          const auto configured=clouds::Quality(quality);
          check(configured[0]==(1u<<(3u-selected)) &&configured[2]==baseline[2]
              &&configured[1]==unsigned(std::ceil(baseline[1]*100.f/percent)),
              "Resolution/step size changes unrelated lighting or sampling settings");
        }
      }
      for(bool custom:{false,true}) {
        resolution->Set(3.f)->Write();steps->Set(50.f)->Write();ApplyTabPreset(preset::graphics,custom);
        check(clouds::resolution==0.f &&clouds::step_size==1.f,"Explicit cloud sampling preset values missing");
        for(const auto& [key,expected]:{std::pair{"GfxCloudDetail",100.f},std::pair{"GfxCloudDetailSize",100.f},
            std::pair{"GfxCloudBaseSoftness",0.f}}) {
          auto* style=ui::FindSetting(key);
          check(style &&style->section=="Cloud Shape" &&!style->tooltip.empty()
              &&style->GetValue()==expected &&style->default_value==expected,"Cloud shape preset/default mismatch");
          style->Set(style->GetMax())->Write();
        }
      }
      check(clouds::Atmosphere(3.f)==std::array<float,4>{3,8,2,1},"Shape settings not packed with independent sky density");
      ui::FindSetting("GfxCloudDetailSize")->Set(50.f)->Write();
      check(clouds::Atmosphere(3.f)==std::array<float,4>{3,8,.2f,1},"Detail range cannot move above/below the new baseline");
      ApplyTabPreset(preset::graphics,true);
      check(clouds::Atmosphere(3.f)==std::array<float,4>{3,4,.4f,0},"Shape preset failed to reset explicit values");
      std::cout<<"PASS independent cloud resolution and step size, bounds, defaults and explicit presets\n";return 0;
    }
    if(argc>1 &&std::string_view(argv[1])=="--player-fill") {
      for(const char* key:{"GfxPlayerFill","GfxPlayerStrength","GfxCutsceneFillStrength","GfxPlayerUnify"}) {
        auto* setting=ui::FindSetting(key);
        check(setting &&setting->section=="Player Lighting" &&!setting->tooltip.empty()
            &&setting->binding,"Fill controls/defaults mismatch");
        for(const auto& value:preset::graphics)if(value.key==key)
          check(setting->default_value==value.custom,"Fill control default differs from its explicit preset");
      }
      ApplyTabPreset(preset::graphics,false);check(witcher3classic::lighting::player_control==0.f,"Vanilla leaves fill override active");
      ApplyTabPreset(preset::graphics,true);
      check(witcher3classic::lighting::player_control==1.f &&witcher3classic::lighting::cutscene_strength==.2f
          &&witcher3classic::lighting::player_unify==1.f,"Custom fill values incomplete");
      std::cout<<"PASS player/cutscene fill menu and explicit preset controls\n";return 0;
    }
    if(argc>1 &&std::string_view(argv[1])=="--water-ssr") {
      for(const auto& [key,value]:{std::pair{"GfxWaterSSRFullResolution",0.f},std::pair{"GfxWaterSSRStabilization",1.f}}) {
        auto* setting=ui::FindSetting(key);
        check(setting &&setting->section=="Water" &&setting->default_value==value
            &&setting->binding &&*setting->binding==value &&!setting->tooltip.empty(),"SSR startup/default/menu mismatch");
      }
      ApplyTabPreset(preset::graphics,false);
      check(witcher3classic::water::ssr_full_resolution==0.f &&witcher3classic::water::ssr_stabilization==0.f,"Vanilla leaves custom SSR active");
      ApplyTabPreset(preset::graphics,true);
      check(witcher3classic::water::ssr_full_resolution==0.f &&witcher3classic::water::ssr_stabilization==1.f,"Custom SSR assignments incomplete");
      check(!custom_shaders.at(0x35624BD6).on_inject(nullptr),"Native water compositor injects settings into native lighting slot");
      std::cout<<"PASS SSR menu/defaults, explicit Vanilla/Custom assignments, native compositor injection bypass\n";
      return 0;
    }
    check(witcher3classic::clouds::quality==1.f
        &&ui::FindSetting("GfxCloudQuality")->labels.size()==6
        &&preset::Default(preset::graphics,"GfxCloudQuality")==1.f,"Cloud quality default or extended levels mismatch");
    for(const auto& [key,expected]:{std::pair{"GfxCloudCoverage",100.f},std::pair{"GfxCloudDensity",100.f},
        std::pair{"GfxCloudSize",100.f},std::pair{"GfxCloudThickness",100.f}}) {
      const auto* setting=ui::FindSetting(key);
      check(setting->section=="Cloud Appearance" &&setting->default_value==expected
          &&setting->binding &&*setting->binding==setting->parse(expected),
          "Cloud appearance startup/reset defaults differ from approved values");
    }
    check(witcher3classic::water::ripple_pattern==1.f
        &&ui::FindSetting("GfxWaterRipplePattern")->section=="Water"
        &&preset::Default(preset::graphics,"GfxWaterRipplePattern")==1.f,"Water ripple pattern startup/default mismatch");
    check(witcher3classic::water::surface_ripples==1.f
        &&ui::FindSetting("GfxWaterSurfaceRipples")->section=="Water"
        &&preset::Default(preset::graphics,"GfxWaterSurfaceRipples")==1.f,"Water ripple startup/default mismatch");
    check(night::enabled==1.f && night::moonlight==35.f && night::full_darkness_start==21.5f,"Runtime night defaults differ from Darker");
    check(!ui::FindSetting("GfxFogLightingResolution") && !ui::FindSetting("GfxFogLocalDistance")
        && !ui::FindSetting("GfxFogPixelLighting"),"Removed fog controls are still exposed");
    check(!ui::FindSetting("GfxWaterCameraDistortion") && !ui::FindSetting("GfxWaterCameraHaze")
        && !ui::FindSetting("GfxWaterCameraTint"),
        "Rejected underwater camera controls are still exposed");
    check(witcher3classic::water::camera_blur==.15f &&witcher3classic::water::camera_ca==1.f
        &&preset::Default(preset::graphics,"GfxWaterCameraBlur")==.15f
        &&preset::Default(preset::graphics,"GfxWaterCameraCA")==1.f,"Underwater camera defaults differ from approved values");
    check(night::exposure::adaptation==1.f &&night::exposure::all_day==1.f &&night::exposure::enabled==1.f
        &&night::exposure::smoothed_brightening_speed==35.f &&night::exposure::smoothed_darkening_speed==5.f
        &&night::exposure::smoothed_maximum_brightening==100.f &&night::exposure::smoothed_maximum_darkening==100.f,
        "Smoothed exposure defaults differ from approved values");
    check(ui::FindSetting("GfxCutsceneFillStrength")->section=="Player Lighting"
        && ui::FindSetting("GfxCutsceneFillStrength")->default_value==.2f
        && witcher3classic::lighting::cutscene_strength==.2f,"Cutscene fill default/section mismatch");
    witcher3classic::lighting::player_strength=.15f;
    ui::FindSetting("GfxCutsceneFillStrength")->Set(.65f)->Write();
    check(witcher3classic::lighting::player_strength==.15f&&witcher3classic::lighting::cutscene_strength==.65f,
        "Cutscene strength changes gameplay strength");
    for(float method:{0.f,1.f}) {
      witcher3classic::volumetrics::renderer=method;
      check(ui::FindSetting("GfxFogReconstruction")->is_visible()==(method==0.f)
          &&ui::FindSetting("GfxFogShadowQuality")->is_visible()==(method==0.f),"Fog method shows unrelated controls");
    }
    witcher3classic::volumetrics::renderer=0.f;
    auto verify=[&](const auto& values,bool custom) {
      for(const auto& value:values) {
        auto* setting=ui::FindSetting(std::string(value.key));
        check(setting && setting->GetValue()==(custom?value.custom:value.vanilla),"Preset assignment is incomplete or wrong");
      }
    };
    auto coverage=[&](const auto& values,std::string_view prefix) {
      std::unordered_set<std::string_view> keys;
      for(const auto& value:values) {
        check(keys.insert(value.key).second,"Duplicate explicit preset entry");
        auto* setting=ui::FindSetting(std::string(value.key));
        check(setting && setting->default_value==value.custom,"UI default differs from explicit custom preset");
        if(prefix=="Night")check(setting->binding && *setting->binding==setting->parse(value.custom),"Runtime night initialization differs from its UI default");
        check(value.vanilla>=setting->min && value.vanilla<=setting->GetMax(),"Vanilla preset value outside slider bounds");
        check(value.custom>=setting->min && value.custom<=setting->GetMax(),"Custom preset value outside slider bounds");
      }
      for(const auto* setting:settings)if(setting->key.starts_with(prefix) && setting->value_type<ui::SettingValueType::BUTTON)
        check(keys.contains(setting->key),"Setting missing from explicit preset");
    };
    coverage(preset::night,"Night");coverage(preset::graphics,"Gfx");
    check(!ui::FindSetting("GfxWaterClarity") && !ui::FindSetting("GfxUnderwater"),"Retired independent water controls remain exposed");
    for(const char* key:{"GfxWater","GfxUnderwaterDensity","GfxWaterCaustics","GfxUnderwaterDetail"})
      check(ui::FindSetting(key)->section=="Water","Water controls are split across sections");
    check(ui::FindSetting("GfxUnderwaterDetail")->format=="%d / 4","Underwater integer slider uses a float display format");
    check(settings[0]->key=="GfxPresetButtons" && settings[1]->key=="NightPresetButtons","Preset sections do not precede tab controls");
    for(unsigned i=0;i<2;++i)check(settings[i]->section=="Presets" && !settings[i]->is_sticky && !settings[i]->can_reset,"Preset section bypasses profile-slider ordering");
    ui::ResetSettings();verify(preset::night,true);verify(preset::graphics,true);
    // Neither button may depend on reset defaults or the previous profile.
    for(auto* setting:settings)if(setting->value_type<ui::SettingValueType::BUTTON) {
      setting->default_value=97.f;setting->Set(0.f)->Write();
    }
    ApplyTabPreset(preset::night,true);verify(preset::night,true);
    for(const auto& value:preset::graphics)check(ui::FindSetting(std::string(value.key))->GetValue()==0.f,"Night preset changes Graphics");
    ApplyTabPreset(preset::night,false);verify(preset::night,false);
    check(!night::exposure::all_day_active && night::exposure::fixed_reference==0.f
        && night::exposure::brightening_range==1.f && night::exposure::darkening_range==1.f,"Vanilla leaves exposure overrides active");
    ApplyTabPreset(preset::graphics,true);verify(preset::graphics,true);verify(preset::night,false);
    ApplyTabPreset(preset::graphics,false);verify(preset::graphics,false);verify(preset::night,false);
    check(witcher3classic::water::mode==0.f && !ui::FindSetting("GfxUnderwaterDensity")->is_enabled()
        && !ui::FindSetting("GfxWaterCaustics")->is_enabled() && !ui::FindSetting("GfxUnderwaterDetail")->is_enabled()
        && !ui::FindSetting("GfxWaterCameraBlur")->is_enabled()
        && !ui::FindSetting("GfxWaterCameraCA")->is_enabled(),
        "Native water does not disable all custom water controls");
    ApplyTabPreset(preset::night,true);OnPresetOff();verify(preset::night,false);
    std::cout<<"PASS complete explicit Graphics/Night presets, default independence, Darker startup/reset defaults, tab isolation, Vanilla/Off exposure bypass and profile-slider ordering\n";
  } catch(const std::exception& error) {std::cerr<<error.what()<<'\n';return 1;}
}
