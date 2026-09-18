/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#pragma once
#include <nvapi.h>
#include <NvApiDriverSettings.h>
#include <filesystem>
#include <condition_variable>
#include <mutex>
#include <thread>
#include "../presentation_protocol.hpp"

namespace acbrotherhood::presentation {
// Read-only driver/display policy. A separate presenter does not necessarily
// inherit the game's application profile or foreground-only Reflex VRR cap.
struct DisplayPolicy {
  HMODULE module = nullptr;
  void* (__cdecl* query)(unsigned) = nullptr;
  decltype(&NvAPI_DRS_CreateSession) create = nullptr;
  decltype(&NvAPI_DRS_DestroySession) destroy = nullptr;
  decltype(&NvAPI_DRS_LoadSettings) load = nullptr;
  decltype(&NvAPI_DRS_FindApplicationByName) find = nullptr;
  decltype(&NvAPI_DRS_GetBaseProfile) base = nullptr;
  decltype(&NvAPI_DRS_GetSetting) setting = nullptr;
  decltype(&NvAPI_DISP_GetDisplayIdByDisplayName) display_id = nullptr;
  decltype(&NvAPI_Disp_GetVRRInfo) vrr_info = nullptr;
  struct Snapshot { uint32_t vsync = VSYNCMODE_PASSIVE, vrr_mode = 0, refresh_hz = 0; bool vrr = false; };
  Snapshot published;
  std::mutex snapshot_mutex, wake_mutex;
  std::condition_variable_any wake;
  std::jthread worker;
  uint32_t vsync = VSYNCMODE_PASSIVE, vrr_mode = 0, refresh_hz = 0;
  bool vrr = false;
  explicit DisplayPolicy(HANDLE parent) {
    module = LoadLibraryW(L"nvapi64.dll");
    if (!module) return;
    query = reinterpret_cast<decltype(query)>(GetProcAddress(module, "nvapi_QueryInterface"));
    if (!query) return;
    auto initialize = reinterpret_cast<decltype(&NvAPI_Initialize)>(query(0x0150e828));
    if (!initialize || initialize() != NVAPI_OK) return;
    create = reinterpret_cast<decltype(create)>(query(0x0694d52e));
    destroy = reinterpret_cast<decltype(destroy)>(query(0xdad9cff8));
    load = reinterpret_cast<decltype(load)>(query(0x375dbd6b));
    find = reinterpret_cast<decltype(find)>(query(0xeee566b2));
    base = reinterpret_cast<decltype(base)>(query(0xda8466a0));
    setting = reinterpret_cast<decltype(setting)>(query(0x73bf8338));
    display_id = reinterpret_cast<decltype(display_id)>(query(0xae457190));
    vrr_info = reinterpret_cast<decltype(vrr_info)>(query(0xdf8fda57));
    wchar_t executable[32768]; DWORD length = DWORD(std::size(executable));
    if (QueryFullProcessImageNameW(parent, 0, executable, &length))
      game = std::filesystem::path(executable).filename().wstring();
  }
  ~DisplayPolicy() {
    if (worker.joinable()) { worker.request_stop(); wake.notify_all(); worker.join(); }
    if (module) FreeLibrary(module);
  }
  void Start(HWND window) {
    published = Read(window);
    worker = std::jthread([this, window](std::stop_token stop) {
      while (!stop.stop_requested()) {
        { std::unique_lock lock(wake_mutex); wake.wait_for(lock, stop, std::chrono::seconds(5), [] { return false; }); }
        if (stop.stop_requested()) break;
        const auto next = Read(window);
        const std::lock_guard lock(snapshot_mutex); published = next;
      }
    });
  }
  std::wstring game;
  Snapshot Read(HWND window) {
    struct Dpi { DPI_AWARENESS_CONTEXT previous; ~Dpi() { SetThreadDpiAwarenessContext(previous); } }
        dpi{SetThreadDpiAwarenessContext(DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2)};
    Snapshot result;
    if (!create || !destroy || !load || !find || !base || !setting || game.empty()) return result;
    NvDRSSessionHandle session = nullptr;
    if (create(&session) != NVAPI_OK) return result;
    struct Close { decltype(destroy) fn; NvDRSSessionHandle handle; ~Close() { fn(handle); } } close{destroy, session};
    if (load(session) != NVAPI_OK) return result;
    NvDRSProfileHandle profile = nullptr;
    NVDRS_APPLICATION application{}; application.version = NVDRS_APPLICATION_VER;
    NvAPI_UnicodeString name{};
    wcsncpy_s(reinterpret_cast<wchar_t*>(name), std::size(name), game.c_str(), _TRUNCATE);
    if (find(session, name, &profile, &application) != NVAPI_OK && base(session, &profile) != NVAPI_OK) return result;
    auto read = [&](NvU32 id, NvU32 fallback) {
      NVDRS_SETTING value{}; value.version = NVDRS_SETTING_VER;
      return setting(session, profile, id, &value) == NVAPI_OK ? value.u32CurrentValue : fallback;
    };
    result.vsync = read(VSYNCMODE_ID, VSYNCMODE_PASSIVE);
    result.vrr_mode = read(VRR_MODE_ID, VRR_MODE_DISABLED);
    if (!result.vrr_mode || read(VRR_APP_OVERRIDE_ID, VRR_APP_OVERRIDE_ALLOW) != VRR_APP_OVERRIDE_ALLOW
        || read(VRR_APP_OVERRIDE_REQUEST_STATE_ID, VRR_APP_OVERRIDE_REQUEST_STATE_ALLOW) != VRR_APP_OVERRIDE_REQUEST_STATE_ALLOW
        || !display_id || !vrr_info) return result;
    MONITORINFOEXW monitor{}; monitor.cbSize = sizeof(monitor);
    if (!GetMonitorInfoW(MonitorFromWindow(window, MONITOR_DEFAULTTONEAREST), &monitor)) return result;
    DEVMODEW mode{}; mode.dmSize = sizeof(mode);
    if (!EnumDisplaySettingsW(monitor.szDevice, ENUM_CURRENT_SETTINGS, &mode) || mode.dmDisplayFrequency <= 1) return result;
    result.refresh_hz = mode.dmDisplayFrequency;
    char display[32]{};
    WideCharToMultiByte(CP_ACP, 0, monitor.szDevice, -1, display, sizeof(display), nullptr, nullptr);
    NvU32 id = 0; NV_GET_VRR_INFO info{}; info.version = NV_GET_VRR_INFO_VER;
    if (display_id(display, &id) != NVAPI_OK || vrr_info(id, &info) != NVAPI_OK
        || !info.bIsVRRPossible) return result;
    // With fullscreen-only G-Sync, the helper's background/child process can
    // report Requested=0 even while the display is in VRR mode. The effective
    // game profile above supplies the user's request; this query proves that
    // the actual output supports it, rather than guessing from refresh rate.
    RECT client{}; GetClientRect(window, &client);
    POINT origin{client.left, client.top}; ClientToScreen(window, &origin);
    const bool fullscreen = origin.x <= monitor.rcMonitor.left && origin.y <= monitor.rcMonitor.top
        && origin.x + client.right >= monitor.rcMonitor.right && origin.y + client.bottom >= monitor.rcMonitor.bottom;
    result.vrr = result.vrr_mode == VRR_MODE_FULLSCREEN_AND_WINDOWED || fullscreen;
    return result;
  }
  void Apply(Packet* packet) {
    { const std::lock_guard lock(snapshot_mutex);
      vsync = published.vsync; vrr_mode = published.vrr_mode;
      refresh_hz = published.refresh_hz; vrr = published.vrr; }

    if (vsync == VSYNCMODE_FORCEON) packet->pacing_state.sync_interval = 1;
    else if (vsync == VSYNCMODE_FORCEOFF) packet->pacing_state.sync_interval = 0;
    // Keep a synchronized VRR frame below the scanout ceiling. Use the same
    // Reflex limiter, in displayed-frame units; never multiply this limit by FG.
    // 0.3 ms headroom gives ~224 FPS at 240 Hz and ~138 FPS at 144 Hz.
    if (vrr && packet->pacing_state.sync_interval && packet->pacing_state.mode && refresh_hz)
      packet->pacing_state.driver_interval_us = std::max(packet->pacing_state.driver_interval_us,
          (1000000u + refresh_hz - 1) / refresh_hz + 300u);
  }
};
}
