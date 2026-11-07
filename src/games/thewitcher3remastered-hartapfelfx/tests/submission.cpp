// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
// Exercise closed Agility command-list creation and the actual producer fence.
#define RENODX_PRIVATE_DATA_NAMESPACE 0x57484658u
#include "../lighting/graphics/water/submission.hpp"
#include "../lighting/graphics/tests/gpu.hpp"
#ifdef HARTAPFELFX_TEST_AGILITY
extern "C" __declspec(dllexport) const UINT D3D12SDKVersion = HARTAPFELFX_TEST_AGILITY;
extern "C" __declspec(dllexport) const char* D3D12SDKPath = ".\\D3D12_0\\";
#endif
namespace api = reshade::api;
namespace submission = witcher3graphics::water::submission;
api::command_list* observed = nullptr;
void Observe(api::command_list* command) { observed = command; }
int main(int argc, char** argv) {
  if (argc != 2 || !LoadLibraryA(argv[1]) || !reshade::register_addon(GetModuleHandleW(nullptr))) return 1;
  submission::UseRuntime(DLL_PROCESS_ATTACH);
  reshade::register_event<reshade::addon_event::init_command_list>(Observe);
  {
    GpuFixture gpu;
    Check(gpu.cmd->Close());
    ComPtr<ID3D12Device4> device;
    Check(gpu.device.As(&device));
    ComPtr<ID3D12GraphicsCommandList> command;
    Check(device->CreateCommandList1(0, D3D12_COMMAND_LIST_TYPE_DIRECT, D3D12_COMMAND_LIST_FLAG_NONE,
                                     IID_PPV_ARGS(&command)));
    auto* owner = observed;
    if (!owner) return 2;
    Check(command->Reset(gpu.allocator.Get(), nullptr));
    // An ordinary recording must not populate the producer registry or make
    // the native submission hook acquire its locks.
    if (submission::active_recordings.load() != 0) return 7;
    {
      std::lock_guard lock(submission::registry_mutex);
      if (!submission::recordings.empty()) return 8;
    }
    // Model an interface alias absent from the creation-time registry.
    // Admission must refresh it before native ExecuteCommandLists runs.
    {
      std::lock_guard lock(submission::registry_mutex);
      auto* data = renodx::utils::data::Get<submission::CommandData>(owner);
      if (!data) return 6;
      std::erase_if(submission::recordings, [&](const auto& entry) { return entry.second == data->recording; });
    }
    const auto lifetime = std::make_shared<submission::Lifetime>();
    if (!submission::Track(owner, lifetime, true)) return 3;
    Check(command->Close());
    ID3D12CommandList* lists[] = {command.Get()};
    gpu.queue->ExecuteCommandLists(1, lists);
    Check(gpu.queue->Signal(gpu.fence.Get(), ++gpu.sequence));
    Check(gpu.fence->SetEventOnCompletion(gpu.sequence, gpu.event));
    if (WaitForSingleObject(gpu.event, 10000) != WAIT_OBJECT_0) return 4;
    Check(command->Reset(gpu.allocator.Get(), nullptr));
    if (!lifetime->Ready() || !lifetime->Idle()) return 5;
    if (submission::active_recordings.load() != 0) return 9;
    Check(command->Close());
  }
  reshade::unregister_event<reshade::addon_event::init_command_list>(Observe);
  submission::UseRuntime(DLL_PROCESS_DETACH);
  reshade::unregister_addon(GetModuleHandleW(nullptr));
  std::cout << "PASS: idle submission bypass, closed native command list, refreshed aliases and completed producer lease\n";
}
