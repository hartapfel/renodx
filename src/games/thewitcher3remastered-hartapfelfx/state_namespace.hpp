// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#pragma once
#include "../../utils/state.hpp"

namespace hartapfelfx::state_namespace {
namespace api = reshade::api;
using Handle = renodx::utils::state::internal::CommandListStateHandle;

// The current backend creates/clears its handle with __uuidof, while its
// lookups honor RENODX_PRIVATE_DATA_NAMESPACE. Keep that backend's allocation
// and destruction, but publish its handle under our private key. Preserve any
// default-namespace owner's handle. This adds no per-draw event or resource scan.
inline void OnInit(api::command_list* cmd) {
  uint64_t previous = 0, owned = 0;
  cmd->get_private_data(reinterpret_cast<const uint8_t*>(&__uuidof(Handle)), &previous);
  renodx::utils::state::OnInitCommandList(cmd);
  cmd->get_private_data(reinterpret_cast<const uint8_t*>(&__uuidof(Handle)), &owned);
  cmd->set_private_data(reinterpret_cast<const uint8_t*>(&renodx::utils::data::GetUuid<Handle>()), owned);
  cmd->set_private_data(reinterpret_cast<const uint8_t*>(&__uuidof(Handle)), previous);
}
inline void OnDestroy(api::command_list* cmd) {
  uint64_t previous = 0;
  cmd->get_private_data(reinterpret_cast<const uint8_t*>(&__uuidof(Handle)), &previous);
  renodx::utils::state::OnDestroyCommandList(cmd);
  cmd->set_private_data(reinterpret_cast<const uint8_t*>(&renodx::utils::data::GetUuid<Handle>()), 0);
  cmd->set_private_data(reinterpret_cast<const uint8_t*>(&__uuidof(Handle)), previous);
}
inline void Use(DWORD reason) {
  auto& owner = renodx::utils::state::shared;
  if (reason == DLL_PROCESS_ATTACH) {
    owner.UnregisterEvent<reshade::addon_event::init_command_list>(renodx::utils::state::OnInitCommandList);
    owner.UnregisterEvent<reshade::addon_event::destroy_command_list>(renodx::utils::state::OnDestroyCommandList);
    owner.RegisterEvent<reshade::addon_event::init_command_list>(OnInit);
    owner.RegisterEvent<reshade::addon_event::destroy_command_list>(OnDestroy);
  } else if (reason == DLL_PROCESS_DETACH) {
    owner.UnregisterEvent<reshade::addon_event::init_command_list>(OnInit);
    owner.UnregisterEvent<reshade::addon_event::destroy_command_list>(OnDestroy);
  }
}
}  // namespace hartapfelfx::state_namespace
