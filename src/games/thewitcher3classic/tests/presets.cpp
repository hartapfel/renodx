/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#include "../addon.cpp"
#include <iostream>
#include <stdexcept>
#include <unordered_set>

int main() {
  namespace ui=renodx::utils::settings;
  namespace preset=witcher3classic::presets;
  namespace night=witcher3classic::night;
  try {
    auto check=[](bool valid,const char* message){if(!valid)throw std::runtime_error(message);};
    ui::settings=&settings;
    ui::preset_index=0; // no config writes or game hooks in this executable
    check(night::enabled==1.f && night::moonlight==35.f && night::full_darkness_start==21.5f,"Runtime night defaults differ from Darker");
    check(witcher3classic::volumetrics::resolution_quality==2.f
        &&preset::Default(preset::graphics,"GfxFogResolutionQuality")==2.f,"Fog sampling default is incorrect");
    check(!ui::FindSetting("GfxFogLightingResolution") && !ui::FindSetting("GfxFogLocalDistance")
        && !ui::FindSetting("GfxFogPixelLighting"),"Removed fog controls are still exposed");
    check(night::exposure::adaptation==1.f &&night::exposure::all_day==1.f &&night::exposure::enabled==1.f
        &&night::exposure::smoothed_brightening_speed==35.f &&night::exposure::smoothed_darkening_speed==5.f
        &&night::exposure::smoothed_maximum_brightening==20.f &&night::exposure::smoothed_maximum_darkening==100.f,
        "Smoothed exposure defaults differ from approved values");
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
    ApplyTabPreset(preset::night,true);OnPresetOff();verify(preset::night,false);
    std::cout<<"PASS complete explicit Graphics/Night presets, default independence, Darker startup/reset defaults, tab isolation, Vanilla/Off exposure bypass and profile-slider ordering\n";
  } catch(const std::exception& error) {std::cerr<<error.what()<<'\n';return 1;}
}
