/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#pragma once
#include <filesystem>
#include <span>
#include <string>
#include <vector>
#include "./dlaa_handles.hpp"

namespace acbrotherhood::helper {
// A child presenter can send synchronous window messages to its parent. Service
// only sent messages while waiting; leave queued game input/events untouched.
inline DWORD WaitForSignals(std::span<const HANDLE> handles, DWORD timeout) {
  const ULONGLONG deadline = GetTickCount64() + timeout;
  for (;;) {
    const ULONGLONG now = GetTickCount64();
    const DWORD result = MsgWaitForMultipleObjectsEx(DWORD(handles.size()), handles.data(),
        now >= deadline ? 0 : DWORD(deadline - now), QS_SENDMESSAGE, MWMO_INPUTAVAILABLE);
    if (result != WAIT_OBJECT_0 + handles.size()) return result;
    MSG message;
    PeekMessageW(&message, nullptr, 0, 0, PM_NOREMOVE);
  }
}
// Explicit inheritance and a kill-on-close job keep an optional worker isolated
// from unrelated game handles. Launch suspended so it cannot escape the job.
inline DWORD Launch(const std::filesystem::path& executable, std::span<const HANDLE> inherited,
                    dlaa::Handle* job, dlaa::Handle* process) {
  *job = dlaa::Handle(CreateJobObjectW(nullptr, nullptr));
  JOBOBJECT_EXTENDED_LIMIT_INFORMATION limits{};
  limits.BasicLimitInformation.LimitFlags = JOB_OBJECT_LIMIT_KILL_ON_JOB_CLOSE;
  if (!job->value || !SetInformationJobObject(job->value, JobObjectExtendedLimitInformation, &limits, sizeof(limits)))
    return GetLastError();
  SIZE_T size = 0;
  InitializeProcThreadAttributeList(nullptr, 1, 0, &size);
  std::vector<unsigned char> attributes(size);
  STARTUPINFOEXW startup{};
  startup.StartupInfo.cb = sizeof(startup);
  startup.lpAttributeList = reinterpret_cast<LPPROC_THREAD_ATTRIBUTE_LIST>(attributes.data());
  if (!InitializeProcThreadAttributeList(startup.lpAttributeList, 1, 0, &size)) return GetLastError();
  const bool updated = UpdateProcThreadAttribute(startup.lpAttributeList, 0, PROC_THREAD_ATTRIBUTE_HANDLE_LIST,
      const_cast<HANDLE*>(inherited.data()), inherited.size_bytes(), nullptr, nullptr);
  std::wstring command = L"\"" + executable.wstring() + L"\"";
  for (auto handle : inherited) command += L" " + std::to_wstring(uintptr_t(handle));
  PROCESS_INFORMATION child{};
  const bool created = updated && CreateProcessW(executable.c_str(), command.data(), nullptr, nullptr, TRUE,
      CREATE_NO_WINDOW | CREATE_SUSPENDED | EXTENDED_STARTUPINFO_PRESENT, nullptr,
      executable.parent_path().c_str(), &startup.StartupInfo, &child);
  const DWORD error = GetLastError();
  DeleteProcThreadAttributeList(startup.lpAttributeList);
  if (!created) return error;
  *process = dlaa::Handle(child.hProcess);
  dlaa::Handle thread(child.hThread);
  if (!AssignProcessToJobObject(job->value, process->value)) {
    const DWORD failure = GetLastError();
    TerminateProcess(process->value, failure);  // Our suspended worker only.
    return failure;
  }
  if (ResumeThread(thread.value) == DWORD(-1)) return GetLastError();
  return ERROR_SUCCESS;
}
}  // namespace acbrotherhood::helper
