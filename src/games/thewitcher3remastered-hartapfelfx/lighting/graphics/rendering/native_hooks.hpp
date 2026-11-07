// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#pragma once
#include <Windows.h>
#include <TlHelp32.h>
#include <detours.h>
#include <span>
#include <vector>

namespace witcher3graphics {
struct NativeHook {
  void** original;
  void* replacement;
};

// Both DXR and queue hooks can remain callable after addon teardown. Pin the
// module and update all live process threads in one atomic Detours transaction.
// Callers serialize installation and keep their inactive hooks pass-through.
inline bool AttachNativeHooks(std::span<const NativeHook> hooks, const void* anchor) {
  if (hooks.empty()) return false;
  HANDLE snapshot = CreateToolhelp32Snapshot(TH32CS_SNAPTHREAD, 0);
  if (snapshot == INVALID_HANDLE_VALUE) return false;
  std::vector<HANDLE> threads;
  THREADENTRY32 entry{sizeof(entry)};
  bool valid = Thread32First(snapshot, &entry) != FALSE;
  if (valid) do {
      if (entry.th32OwnerProcessID != GetCurrentProcessId() || entry.th32ThreadID == GetCurrentThreadId()) continue;
      HANDLE thread = OpenThread(THREAD_SUSPEND_RESUME | THREAD_GET_CONTEXT | THREAD_SET_CONTEXT | THREAD_QUERY_INFORMATION,
          FALSE, entry.th32ThreadID);
      if (!thread) { if (GetLastError() == ERROR_INVALID_PARAMETER) continue; valid = false; break; }
      threads.push_back(thread);
    } while (Thread32Next(snapshot, &entry));
  CloseHandle(snapshot);
  HMODULE pinned = nullptr;
  valid = valid && GetModuleHandleExW(GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS | GET_MODULE_HANDLE_EX_FLAG_PIN,
      reinterpret_cast<LPCWSTR>(anchor), &pinned);
  bool installed = false;
  if (valid && DetourTransactionBegin() == NO_ERROR) {
    valid = DetourUpdateThread(GetCurrentThread()) == NO_ERROR;
    for (HANDLE thread : threads) if (valid) valid = DetourUpdateThread(thread) == NO_ERROR;
    for (const auto& hook : hooks)
      if (valid) valid = DetourAttach(hook.original, hook.replacement) == NO_ERROR;
    if (valid) installed = DetourTransactionCommit() == NO_ERROR;
    else DetourTransactionAbort();
  }
  for (HANDLE thread : threads) CloseHandle(thread);
  return installed;
}
}  // namespace witcher3graphics
