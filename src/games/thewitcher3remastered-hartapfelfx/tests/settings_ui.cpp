// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#include <iostream>
#include <stdexcept>
// Bind the standalone test to real ImGui rather than the addon's ReShade table.
#include <include/reshade.hpp>
#include "../settings_ui.hpp"
#include <deps/imgui/imgui_internal.h>
extern "C" __declspec(dllexport) const char* const NAME="HartapfelFX settings test";
int main() {
  using namespace hartapfelfx::ui;
  try {
    float coverage=0, fog=0, light=0, moon=0, exposure=0, global=0;
    Setting cloud{.key="CloudCoverageV2",.binding=&coverage,.default_value=100.f,
        .parse=[](float value){return value*.01f;}};
    Setting mist{.key="FogDensity",.binding=&fog,.default_value=100.f};
    Setting surface{.key="PBRLighting",.binding=&light,.value_type=ValueType::INTEGER,.default_value=1.f};
    Setting disc{.key="MoonSize",.binding=&moon,.default_value=75.f};
    Setting hidden{.key="NightExposureBrighteningSpeed",.binding=&exposure,.default_value=35.f,
        .is_visible=[] {return false;}};
    Setting sticky{.key="CloudGlobal",.binding=&global,.default_value=10.f,.is_global=true};
    Setting hint{.value_type=ValueType::TEXT,.label="Not a control"};
    Settings settings{&cloud,&mist,&surface,&disc,&hidden,&sticky,&hint};
    for(Tab tab:tabs) {
      for(auto* setting:settings)if(setting->binding)setting->Set(23.f)->Write();
      ResetTab(settings,tab);
      for(auto* setting:settings) {
        if(!setting->binding)continue;
        const float expected=!setting->is_global &&TabForKey(setting->key)==tab ? setting->default_value : 23.f;
        if(setting->GetValue()!=expected ||*setting->binding!=setting->parse(expected))
          throw std::runtime_error("Reset crossed tab boundaries or missed a hidden control");
      }
    }
    if(TabForKey("SunSize")!=Tab::Lighting ||TabForKey("MoonSize")!=Tab::Lighting
        ||TabForKey("NightLightingEnabled")!=Tab::Nights)
      throw std::runtime_error("Independent sky-disc controls have incorrect ownership");
    cloud.tooltip="Changes coverage.";mist.tooltip="Changes fog.";disc.tooltip="Changes moon size.";
    hidden.tooltip="Changes exposure speed.";
    Configure(&settings);
    if(settings.size()!=7 ||cloud.tooltip!="Changes coverage." ||hidden.tooltip!="Changes exposure speed.")
      throw std::runtime_error("Configuration added inline hints or lost hover help");
    if(renodx::utils::settings::use_presets)throw std::runtime_error("Legacy preset controls would be duplicated");
    for(Tab tab:tabs) {
      selected=tab;
      for(auto* setting:settings) {
        if(IsValue(setting) &&setting!=&hidden &&setting->is_visible()!=(TabForKey(setting->key)==tab))
          throw std::runtime_error("Tab filter hid or exposed an unrelated control");
      }
    }
    if(hidden.is_visible())throw std::runtime_error("Conditional exposure visibility was lost");
    renodx::utils::settings::settings=&settings;
    renodx::utils::settings::preset_index=1;
    for(auto* setting:settings)if(IsValue(setting))setting->Set(setting->default_value)->Write();
    ImGui::CreateContext();
    auto& io=ImGui::GetIO();
    io.DisplaySize=ImVec2(800,1200);io.DeltaTime=1.f/60.f;io.IniFilename=nullptr;
    unsigned char* pixels=nullptr;int width=0,height=0;
    io.Fonts->GetTexDataAsRGBA32(&pixels,&width,&height);
    auto check_footer=[] {
      const std::string_view text=ImGui::GetCurrentContext()->LogBuffer.c_str();
      for(const char* label:{"Help & About","RenoDX Discord","HDR Den Discord","GitHub","Hartapfel's Ko-Fi","ShortFuse's Ko-Fi","Build:"})
        if(text.find(label)==std::string_view::npos)throw std::runtime_error("Shared Help & About section is incomplete");
      for(const char* tooltip:{"Changes coverage.","Changes fog.","Changes moon size.","Changes exposure speed."})
        if(text.find(tooltip)!=std::string_view::npos)throw std::runtime_error("A hover hint was rendered inline");
      if(ImGui::GetCurrentContext()->OpenPopupStack.Size)throw std::runtime_error("Help opened as a popup");
    };
    for(Tab tab:tabs)for(uint32_t warmup=0;warmup<2;++warmup) {
      ImGui::NewFrame();
      ImGui::SetNextWindowPos(ImVec2(0,0));ImGui::SetNextWindowSize(ImVec2(760,1100));
      ImGui::Begin("HartapfelFX preview");
      if(auto* bar=ImGui::GetCurrentContext()->TabBars.GetByKey(ImGui::GetID("HartapfelFXTabs"));bar &&bar->Tabs.Size==4) {
        bar->SelectedTabId=bar->Tabs[int(tab)].ID;bar->NextSelectedTabId=bar->SelectedTabId;
      }
      ImGui::LogToBuffer();Draw(settings,nullptr);check_footer();ImGui::LogFinish();
      ImGui::End();ImGui::Render();
      if(warmup &&(selected!=tab ||ImGui::GetDrawData()->TotalVtxCount<100))
        throw std::runtime_error("A settings tab failed to draw with real ImGui");
    }
    renodx::utils::settings::preset_index=0;
    ImGui::NewFrame();ImGui::Begin("HartapfelFX preview");
    ImGui::LogToBuffer();Draw(settings,nullptr);check_footer();ImGui::LogFinish();
    ImGui::End();ImGui::Render();ImGui::DestroyContext();
    std::cout<<"PASS four scoped resets, hidden values, parsing, hover-only hints, four ImGui tabs and shared Help/support section with Preset Off\n";
    return 0;
  }catch(const std::exception& error){std::cerr<<error.what()<<'\n';return 1;}
}
