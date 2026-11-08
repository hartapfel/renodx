// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#pragma once
#include <algorithm>
#include <array>
#include <string_view>
#include "../../utils/settings.hpp"
#include "../../utils/date.hpp"
#include "../../utils/platform.hpp"

namespace hartapfelfx::ui {
using Setting = renodx::utils::settings::Setting;
using Settings = renodx::utils::settings::Settings;
using ValueType = renodx::utils::settings::SettingValueType;
enum class Tab { Clouds, Fog, Lighting, Nights };
inline constexpr std::array tabs{Tab::Clouds,Tab::Fog,Tab::Lighting,Tab::Nights};
inline constexpr std::array names{"Clouds","Fog","Lighting","Nights"};
inline Tab selected = Tab::Clouds;

inline Tab TabForKey(std::string_view key) {
  if(key.starts_with("Cloud"))return Tab::Clouds;
  if(key.starts_with("Fog"))return Tab::Fog;
  if(key.empty() ||key.starts_with("Night"))return Tab::Nights;
  return Tab::Lighting;
}
inline bool IsValue(const Setting* setting) {
  return !setting->key.empty() &&setting->binding &&!setting->is_global
      &&setting->value_type<=ValueType::BOOLEAN;
}
// Reset uses ownership, not visibility: collapsed sections and conditional
// exposure controls still reset, while settings on other tabs cannot change.
inline void ResetTab(const Settings& settings, Tab tab) {
  for(auto* setting:settings) {
    if(!IsValue(setting) ||!setting->can_reset ||TabForKey(setting->key)!=tab)continue;
    const float before=setting->GetValue();
    {
      const std::unique_lock lock(renodx::utils::mutex::global_mutex);
      setting->Set(setting->default_value)->Write();
    }
    setting->on_change();
    setting->on_change_value(before,setting->GetValue());
  }
}
inline void Configure(Settings* settings) {
  renodx::utils::settings::use_presets=false;
  Setting* cloud_mode=nullptr;
  Setting* fog_mode=nullptr;
  for(auto* setting:*settings) {
    if(setting->key=="CloudModeV2")cloud_mode=setting;
    if(setting->key=="FogEnabled")fog_mode=setting;
  }
  // Keep sections contiguous, including Sun/Moon Appearance moved from Nights.
  constexpr std::array<std::string_view,23> order{
      "Clouds & Performance","Cloud Appearance","Cloud Formation","Cloud Edges","Cloud Lighting",
      "Cloud Structure (Advanced)","Cloud Detail (Advanced)","Cloud Erosion (Advanced)",
      "Fog & Performance","Fog Appearance","Light in Fog","Fog Placement","Diagnostics (Advanced)",
      "World Lighting & Shadows","Sun & Moon Appearance","Character Lighting",
      "Night Lighting","Night Brightness","Night Atmosphere","Night Colour","Night Schedule",
      "Exposure","Exposure Tuning (Advanced)"};
  std::stable_sort(settings->begin(),settings->end(),[&](auto* left,auto* right) {
    return std::find(order.begin(),order.end(),left->section)<std::find(order.begin(),order.end(),right->section);
  });
  for(auto* setting:*settings) {
    const Tab tab=TabForKey(setting->key);
    auto* master=tab==Tab::Clouds ? cloud_mode : tab==Tab::Fog ? fog_mode : nullptr;
    if(master &&master!=setting &&IsValue(setting) &&setting->key!="FogSkyDensity") {
      setting->is_enabled=[master,enabled=std::move(setting->is_enabled)] {
        return master->binding &&*master->binding>.5f &&(!enabled ||enabled());
      };
    }
    if(setting->value_type==ValueType::FLOAT
        &&((tab==Tab::Clouds &&setting->key!="CloudBaseAltitudeV1"
                &&setting->key!="CloudRoundnessV1" &&setting->key!="CloudWispBiasV1")
            ||setting->key=="FogDensity" ||setting->key=="FogSunlight"
            ||setting->key=="FogLocalLight" ||setting->key=="FogHeight" ||setting->key=="FogSkyDensity"))
      setting->format="%.0f%%";
    setting->is_visible=[tab,visible=std::move(setting->is_visible)] {
      return selected==tab &&(!visible ||visible());
    };
  }
}

inline void DrawHelp() {
  if(!ImGui::TreeNodeEx("Help & About",ImGuiTreeNodeFlags_DefaultOpen|ImGuiTreeNodeFlags_SpanFullWidth))return;
  ImGui::Unindent();
  ImGui::TextWrapped("Clouds, fog, lighting and nights for The Witcher 3 Remastered.");
  ImGui::TextWrapped("Hover controls for help. Changes save automatically. Reset All restores this tab; Preset Off restores original effects.");
  struct Link { const char* label; const char* url; const char* hint; uint32_t tint; unsigned row; };
  static constexpr std::array links{
      Link{"RenoDX Discord","https://discord.gg/Ce9bQHQrSV","Community help, discussion and updates.",0x5865F2,0},
      Link{"HDR Den Discord","https://discord.gg/5WZXDpmbpP","HDR help and discussion.",0x5865F2,0},
      Link{"GitHub","https://github.com/clshortfuse/renodx","RenoDX source code and issue reports.",0x2B3137,0},
      Link{"Hartapfel's Ko-Fi","https://ko-fi.com/hartapfel","Support the creator of this game mod.",0xFF5A16,1},
      Link{"ShortFuse's Ko-Fi","https://ko-fi.com/shortfuse","Support the creator of the RenoDX framework.",0xFF5A16,1}};
  for(size_t index=0;index<links.size();++index) {
    const auto& link=links[index];
    if(index &&link.row==links[index-1].row
        &&ImGui::GetItemRectMax().x+ImGui::GetStyle().ItemSpacing.x
            +ImGui::CalcTextSize(link.label).x+2.f*ImGui::GetStyle().FramePadding.x
            <=ImGui::GetCursorScreenPos().x+ImGui::GetContentRegionAvail().x)
      ImGui::SameLine();
    // Match the framework's tinted buttons while retaining the user's theme.
    const auto tint=renodx::utils::settings::ImVec4FromHex(link.tint);
    float hue,saturation,value;
    ImGui::ColorConvertRGBtoHSV(tint.x,tint.y,tint.z,hue,saturation,value);
    for(auto style:{ImGuiCol_Button,ImGuiCol_ButtonHovered,ImGuiCol_ButtonActive}) {
      auto colour=ImGui::GetStyleColorVec4(style);
      float original_hue;
      ImGui::ColorConvertRGBtoHSV(colour.x,colour.y,colour.z,original_hue,saturation,value);
      ImGui::ColorConvertHSVtoRGB(hue,saturation,value,colour.x,colour.y,colour.z);
      ImGui::PushStyleColor(style,colour);
    }
    if(ImGui::Button(link.label))renodx::utils::platform::LaunchURL(link.url);
    ImGui::PopStyleColor(3);
    ImGui::SetItemTooltip("%s",link.hint);
  }
  ImGui::TextWrapped("Game mod by Hartapfel; RenoDX framework by ShortFuse.");
  ImGui::Text("Build: %s",renodx::utils::date::ISO_DATE_TIME);
  ImGui::Indent();
  ImGui::TreePop();
}
inline void Draw(const Settings& settings, reshade::api::effect_runtime* runtime) {
  namespace options=renodx::utils::settings;
  if(ImGui::SliderInt("Preset",&options::preset_index,0,int(options::preset_strings.size())-1,
      options::preset_strings[options::preset_index].c_str(),ImGuiSliderFlags_NoInput)) {
    if(options::preset_index==0)for(auto& callback:options::on_preset_off_callbacks)callback();
    else options::LoadSettings(options::GetCurrentPresetName());
    for(auto& callback:options::on_preset_changed_callbacks)callback();
  }
  if(!ImGui::BeginTabBar("HartapfelFXTabs"))return;
  for(Tab tab:tabs) {
    const char* name=names[size_t(tab)];
    if(!ImGui::BeginTabItem(name))continue;
    selected=tab;
    ImGui::PushID(name);
    ImGui::BeginDisabled(options::preset_index==0);
    if(ImGui::Button("Reset All"))ImGui::OpenPopup("Restore tab defaults");
    ImGui::EndDisabled();
    ImGui::SetItemTooltip("Restore every %s setting in this preset. Other tabs keep their values.",name);
    ImGui::SetNextWindowSize(ImVec2(ImGui::GetFontSize()*28.f,0),ImGuiCond_Appearing);
    if(ImGui::BeginPopupModal("Restore tab defaults",nullptr,ImGuiWindowFlags_AlwaysAutoResize)) {
      ImGui::TextWrapped("Restore all %s settings in Preset #%d to the mod defaults?",name,options::preset_index);
      ImGui::TextWrapped("This includes collapsed and hidden options on this tab. Other tabs and presets keep their values.");
      if(ImGui::Button("Restore Defaults")) {
        ResetTab(settings,tab);
        options::SaveSettings();
        ImGui::CloseCurrentPopup();
      }
      ImGui::SameLine();
      if(ImGui::Button("Cancel"))ImGui::CloseCurrentPopup();
      ImGui::EndPopup();
    }
    // One level of disclosure; user-opened sections retain their state.
    for(auto* setting:settings) {
      if(TabForKey(setting->key)!=tab ||!setting->section.ends_with("(Advanced)"))continue;
      const auto id=ImGui::GetID(setting->section.c_str());
      if(ImGui::GetStateStorage()->GetInt(id,-1)==-1)ImGui::GetStateStorage()->SetInt(id,0);
    }
    options::OnRegisterOverlay(runtime);
    ImGui::PopID();
    ImGui::EndTabItem();
  }
  ImGui::EndTabBar();
  DrawHelp();
}
}  // namespace hartapfelfx::ui
