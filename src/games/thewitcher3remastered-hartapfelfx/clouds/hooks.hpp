// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#pragma once
#include <detours.h>
#include <map>
#include <mutex>
#include "../../../utils/log.hpp"
namespace hartapfelfx::clouds::hooks {
struct Target { void* original; void* callback; };
inline std::mutex mutex;
inline std::map<void*, Target> targets;
inline bool Attach(void* function, void* callback) {
  std::lock_guard lock(mutex);
  if (const auto found = targets.find(function); found != targets.end()) return found->second.callback == callback;
  auto [entry, inserted] = targets.emplace(function, Target{function, callback});
  if (DetourTransactionBegin() != NO_ERROR) { targets.erase(entry); return false; }
  if (DetourUpdateThread(GetCurrentThread()) != NO_ERROR || DetourAttach(&entry->second.original, callback) != NO_ERROR
      || DetourTransactionCommit() != NO_ERROR) {
    DetourTransactionAbort(); targets.erase(entry);
    renodx::utils::log::e("HartapfelFX native hook attachment failed");
    return false;
  }
  return true;
}
inline void* Original(void* function) {
  std::lock_guard lock(mutex);
  return targets.at(function).original;
}
inline void Detach() {
  std::lock_guard lock(mutex);
  for (auto& [function, target] : targets) {
    if (DetourTransactionBegin() != NO_ERROR) continue;
    if (DetourUpdateThread(GetCurrentThread()) != NO_ERROR || DetourDetach(&target.original, target.callback) != NO_ERROR
        || DetourTransactionCommit() != NO_ERROR) {
      DetourTransactionAbort();
      renodx::utils::log::e("HartapfelFX native hook detachment failed");
    }
  }
  targets.clear();
}
}  // namespace hartapfelfx::clouds::hooks
