/*
 * Copyright (C) 2026 Hartapfel
 * SPDX-License-Identifier: MIT
 */

#pragma once

// Opt-in Release support build: /DGOTSUSHIMA_CRASH_DIAGNOSTICS=1.
// Enable DRED before device creation; do not enable GPU validation or change TDR.
#include <d3d12.h>
#include <dxgi.h>
#include <algorithm>
#include <atomic>
#include <sstream>
#include <string>

#include <include/reshade.hpp>

namespace gotsushima::crash_diagnostics {

inline void Log(const std::string& message) {
  reshade::log::message(reshade::log::level::info, ("[GHOST-CRASH-DIAG v1] " + message).c_str());
}

inline std::string Result(HRESULT result) {
  std::ostringstream line;
  line << "0x" << std::hex << static_cast<uint32_t>(result);
  switch (result) {
    case S_OK: line << " S_OK"; break;
    case DXGI_ERROR_DEVICE_HUNG: line << " DXGI_ERROR_DEVICE_HUNG"; break;
    case DXGI_ERROR_DEVICE_REMOVED: line << " DXGI_ERROR_DEVICE_REMOVED"; break;
    case DXGI_ERROR_DEVICE_RESET: line << " DXGI_ERROR_DEVICE_RESET"; break;
    case DXGI_ERROR_DRIVER_INTERNAL_ERROR: line << " DXGI_ERROR_DRIVER_INTERNAL_ERROR"; break;
    default: break;
  }
  return line.str();
}

inline std::string ObjectName(const char* narrow, const wchar_t* wide) {
  // DRED strings are runtime-owned. Bound the amount copied into the log.
  std::string result;
  for (size_t i = 0; i < 256; ++i) {
    const auto value = narrow != nullptr ? static_cast<unsigned char>(narrow[i]) : wide != nullptr ? wide[i] : 0;
    if (value == 0) break;
    result += value >= 32 && value < 127 ? static_cast<char>(value) : '?';
  }
  return result.empty() ? "<unnamed>" : result;
}

inline const char* Operation(D3D12_AUTO_BREADCRUMB_OP op) {
  switch (op) {
    case D3D12_AUTO_BREADCRUMB_OP_DRAWINSTANCED: return "DrawInstanced";
    case D3D12_AUTO_BREADCRUMB_OP_DRAWINDEXEDINSTANCED: return "DrawIndexedInstanced";
    case D3D12_AUTO_BREADCRUMB_OP_DISPATCH: return "Dispatch";
    case D3D12_AUTO_BREADCRUMB_OP_EXECUTEINDIRECT: return "ExecuteIndirect";
    case D3D12_AUTO_BREADCRUMB_OP_EXECUTEBUNDLE: return "ExecuteBundle";
    case D3D12_AUTO_BREADCRUMB_OP_COPYRESOURCE: return "CopyResource";
    case D3D12_AUTO_BREADCRUMB_OP_COPYTEXTUREREGION: return "CopyTextureRegion";
    case D3D12_AUTO_BREADCRUMB_OP_COPYBUFFERREGION: return "CopyBufferRegion";
    case D3D12_AUTO_BREADCRUMB_OP_RESOURCEBARRIER: return "ResourceBarrier";
    case D3D12_AUTO_BREADCRUMB_OP_CLEARRENDERTARGETVIEW: return "ClearRenderTargetView";
    case D3D12_AUTO_BREADCRUMB_OP_RESOLVESUBRESOURCE: return "ResolveSubresource";
    case D3D12_AUTO_BREADCRUMB_OP_SETPROTECTEDRESOURCESESSION: return "SetProtectedResourceSession";
    case D3D12_AUTO_BREADCRUMB_OP_BEGINEVENT: return "BeginEvent";
    case D3D12_AUTO_BREADCRUMB_OP_ENDEVENT: return "EndEvent";
    case D3D12_AUTO_BREADCRUMB_OP_SETMARKER: return "SetMarker";
    default: return "Other (see numeric D3D12_AUTO_BREADCRUMB_OP)";
  }
}

inline void DumpAllocations(const char* kind, const D3D12_DRED_ALLOCATION_NODE1* node) {
  uint32_t count = 0;
  for (; node != nullptr && count < 64; node = node->pNext, ++count) {
    std::ostringstream line;
    line << "ALLOCATION " << kind << " type=" << static_cast<uint32_t>(node->AllocationType)
         << " object=" << node->pObject << " name=" << ObjectName(node->ObjectNameA, node->ObjectNameW);
    Log(line.str());
  }
  Log(std::string("ALLOCATION_SUMMARY ") + kind + " count=" + std::to_string(count) + " truncated=" + std::to_string(node != nullptr));
}

inline void DumpDred(ID3D12Device* device) {
  ID3D12DeviceRemovedExtendedData1* dred = nullptr;
  const HRESULT query = device->QueryInterface(IID_PPV_ARGS(&dred));
  Log("DRED interface=" + Result(query));
  if (FAILED(query)) return;

  D3D12_DRED_AUTO_BREADCRUMBS_OUTPUT1 breadcrumbs = {};
  const HRESULT breadcrumbs_result = dred->GetAutoBreadcrumbsOutput1(&breadcrumbs);
  Log("BREADCRUMBS result=" + Result(breadcrumbs_result));
  uint32_t visited = 0;
  uint32_t incomplete = 0;
  uint32_t reported = 0;
  const auto* node = SUCCEEDED(breadcrumbs_result) ? breadcrumbs.pHeadAutoBreadcrumbNode : nullptr;
  for (; node != nullptr && visited < 4096; node = node->pNext, ++visited) {
    const UINT completed = node->pLastBreadcrumbValue != nullptr ? *node->pLastBreadcrumbValue : 0;
    if (node->pLastBreadcrumbValue != nullptr && completed == node->BreadcrumbCount) continue;
    ++incomplete;
    if (reported++ >= 32) continue;
    std::ostringstream line;
    line << "BREADCRUMB_LIST cmd=" << node->pCommandList << " name="
         << ObjectName(node->pCommandListDebugNameA, node->pCommandListDebugNameW)
         << " queue=" << node->pCommandQueue << " queue_name="
         << ObjectName(node->pCommandQueueDebugNameA, node->pCommandQueueDebugNameW)
         << " completed=" << completed << " total=" << node->BreadcrumbCount
         << " progress_available=" << (node->pLastBreadcrumbValue != nullptr);
    Log(line.str());
    // Completed is a count; history[completed] is the first unconfirmed operation.
    // GPU pipelining means this is a lead, not proof of the faulting operation.
    const UINT cursor = (std::min)(completed, node->BreadcrumbCount);
    const UINT start = cursor > 8 ? cursor - 8 : 0;
    const UINT end = cursor + (std::min)(8u, node->BreadcrumbCount - cursor);
    if (node->pCommandHistory != nullptr) {
      for (UINT i = start; i < end; ++i) {
        std::ostringstream row;
        row << "OP index=" << i << " first_unconfirmed=" << (i == completed);
        // DRED retains the last 65536 operations in a ring, while the completed
        // counter can keep growing. Never index the history with that counter.
        if (node->BreadcrumbCount - i > 65536u) {
          row << " history_overwritten=1";
        } else {
          row << " code=" << static_cast<uint32_t>(node->pCommandHistory[i % 65536u])
              << " name=" << Operation(node->pCommandHistory[i % 65536u]);
        }
        Log(row.str());
      }
    }
    if (node->pBreadcrumbContexts != nullptr) {
      for (UINT i = 0; i < (std::min)(node->BreadcrumbContextsCount, 1024u); ++i) {
        const auto& context = node->pBreadcrumbContexts[i];
        if (context.BreadcrumbIndex < start || context.BreadcrumbIndex >= end) continue;
        Log("CONTEXT index=" + std::to_string(context.BreadcrumbIndex) + " text=" + ObjectName(nullptr, context.pContextString));
      }
    }
  }
  Log("BREADCRUMB_SUMMARY visited=" + std::to_string(visited) + " incomplete=" + std::to_string(incomplete)
      + " list_truncated=" + std::to_string(node != nullptr) + "; at most 32 incomplete lists detailed");

  D3D12_DRED_PAGE_FAULT_OUTPUT1 fault = {};
  const HRESULT fault_result = dred->GetPageFaultAllocationOutput1(&fault);
  std::ostringstream line;
  line << "PAGE_FAULT result=" << Result(fault_result) << " VA=0x" << std::hex << fault.PageFaultVA;
  Log(line.str());
  if (SUCCEEDED(fault_result)) {
    DumpAllocations("existing", fault.pHeadExistingAllocationNode);
    DumpAllocations("recently_freed", fault.pHeadRecentFreedAllocationNode);
  }
  Log("No page-fault address or empty breadcrumbs does not rule out a GPU hang.");
  dred->Release();
}

struct __declspec(uuid("9d88a79c-39c7-407d-a2e7-142975f96264")) DeviceState {
  // Borrowed while the ReShade device is alive. Stop and drain the timer in
  // destroy_device, before ReShade releases the native device or unloads addons.
  ID3D12Device* native = nullptr;
  PTP_TIMER timer = nullptr;
  std::atomic_bool reported = false;
};

inline void CheckDevice(DeviceState* state) {
  if (state->reported.load(std::memory_order_relaxed)) return;
  const HRESULT reason = state->native->GetDeviceRemovedReason();
  if (SUCCEEDED(reason) || state->reported.exchange(true)) return;
  std::ostringstream line;
  line << "DEVICE_LOST BEGIN native=" << state->native << " reason=" << Result(reason);
  Log(line.str());
  DumpDred(state->native);
  Log("DEVICE_LOST END; CPU MATCH/PS/CS lines are recording evidence, not GPU completion evidence.");
}

inline void CALLBACK OnTimer(PTP_CALLBACK_INSTANCE, void* context, PTP_TIMER) {
  CheckDevice(static_cast<DeviceState*>(context));
}

inline bool OnCreateDevice(reshade::api::device_api api, uint32_t&) {
  if (api != reshade::api::device_api::d3d12) return false;
  // ReShade calls create_device outside the loader lock, before D3D12CreateDevice.
  const auto module = GetModuleHandleW(L"d3d12.dll");
  const auto get_debug = module == nullptr ? nullptr : reinterpret_cast<HRESULT(WINAPI*)(REFIID, void**)>(GetProcAddress(module, "D3D12GetDebugInterface"));
  if (get_debug == nullptr) {
    Log("DRED_ENABLE unavailable: D3D12GetDebugInterface not found");
    return false;
  }
  ID3D12DeviceRemovedExtendedDataSettings* settings = nullptr;
  const HRESULT result = get_debug(IID_PPV_ARGS(&settings));
  Log("DRED_ENABLE before device creation result=" + Result(result));
  if (SUCCEEDED(result)) {
    settings->SetAutoBreadcrumbsEnablement(D3D12_DRED_ENABLEMENT_FORCED_ON);
    settings->SetPageFaultEnablement(D3D12_DRED_ENABLEMENT_FORCED_ON);
    ID3D12DeviceRemovedExtendedDataSettings1* contexts = nullptr;
    const HRESULT contexts_result = settings->QueryInterface(IID_PPV_ARGS(&contexts));
    Log("DRED_CONTEXT_ENABLE result=" + Result(contexts_result));
    if (SUCCEEDED(contexts_result)) {
      contexts->SetBreadcrumbContextEnablement(D3D12_DRED_ENABLEMENT_FORCED_ON);
      contexts->Release();
    }
    settings->Release();
  }
  return false;
}

inline void OnInitDevice(reshade::api::device* device) {
  if (device->get_api() != reshade::api::device_api::d3d12) return;
  auto* state = device->create_private_data<DeviceState>();
  state->native = reinterpret_cast<ID3D12Device*>(device->get_native());
  state->timer = CreateThreadpoolTimer(OnTimer, state, nullptr);
  std::ostringstream line;
  line << "DEVICE_INIT native=" << state->native << " initial_status=" << Result(state->native->GetDeviceRemovedReason())
       << " monitor=" << (state->timer != nullptr);
  if (state->timer == nullptr) line << " win32_error=" << GetLastError();
  Log(line.str());
  if (state->timer != nullptr) {
    // Negative FILETIME schedules a relative delay in 100 ns units.
    ULARGE_INTEGER due;
    due.QuadPart = static_cast<ULONGLONG>(-2500000LL);
    FILETIME time = {due.LowPart, due.HighPart};
    SetThreadpoolTimer(state->timer, &time, 250, 0);
  }
}

inline void OnDestroyDevice(reshade::api::device* device) {
  auto* state = device->get_private_data<DeviceState>();
  if (state == nullptr) return;
  if (state->timer != nullptr) {
    SetThreadpoolTimer(state->timer, nullptr, 0, 0);
    WaitForThreadpoolTimerCallbacks(state->timer, TRUE);
    CloseThreadpoolTimer(state->timer);
  }
  CheckDevice(state);
  Log("DEVICE_DESTROY status=" + Result(state->native->GetDeviceRemovedReason()));
  device->destroy_private_data<DeviceState>();
}

inline void Use(DWORD reason) {
  if (reason == DLL_PROCESS_ATTACH) {
    Log("START Release " __DATE__ " " __TIME__ "; DRED + 250ms device monitor; normal shaders/injection policy; no debug layer or GPU validation");
    reshade::register_event<reshade::addon_event::create_device>(OnCreateDevice);
    reshade::register_event<reshade::addon_event::init_device>(OnInitDevice);
    reshade::register_event<reshade::addon_event::destroy_device>(OnDestroyDevice);
  } else if (reason == DLL_PROCESS_DETACH) {
    // Timers have already been drained by destroy_device. Never wait in DllMain.
    reshade::unregister_event<reshade::addon_event::create_device>(OnCreateDevice);
    reshade::unregister_event<reshade::addon_event::init_device>(OnInitDevice);
    reshade::unregister_event<reshade::addon_event::destroy_device>(OnDestroyDevice);
  }
}

}  // namespace gotsushima::crash_diagnostics
