// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#pragma once
#include <array>
#include <atomic>
#include <memory>
#include <mutex>
#include <unordered_map>
#include <wrl/client.h>
#include "../rendering/native_hooks.hpp"
#include "../rendering/bindings.hpp"
#include "../../../../../utils/directx.hpp"

namespace witcher3graphics::water::submission {
using namespace reshade::api;
using Microsoft::WRL::ComPtr;

struct Fence {
  ComPtr<ID3D12Fence> native;
  std::atomic_bool failed{false};
};
struct Ticket {
  std::shared_ptr<Fence> fence;
  uint64_t value = 0;
  bool Complete() const {
    if (!fence || !value || fence->failed.load(std::memory_order_acquire)) return false;
    const uint64_t completed = fence->native->GetCompletedValue();
    return completed != UINT64_MAX && completed >= value;
  }
};

// One generation of an immutable field. Command recordings hold shared leases;
// after they reset, tickets retain every queue's GPU completion requirement.
// Pool reuse additionally requires that its own shared_ptr is the only lease.
class Lifetime {
 public:
  bool RecordWrite() {
    std::lock_guard lock(mutex_);
    if (write_recorded_ || poisoned_) return false;
    write_recorded_ = true;
    return true;
  }
  void Seal() { std::lock_guard lock(mutex_); sealed_ = true; }
  void Poison() { std::lock_guard lock(mutex_); poisoned_ = true; }
  void BeginSubmission() { std::lock_guard lock(mutex_); ++submitting_; }
  void Submitted(const Ticket& ticket, bool write) {
    std::lock_guard lock(mutex_);
    if (submitting_) --submitting_;
    if (!ticket.fence || !ticket.value) { poisoned_ = true; return; }
    if (write) producer_ = ticket;
    for (auto& pending : pending_) {
      if (!pending.fence || pending.fence == ticket.fence) {
        if (!pending.fence || pending.value < ticket.value) pending = ticket;
        return;
      }
    }
    poisoned_ = true; // Unsupported queue count: retain, never overwrite.
  }
  bool Ready() const {
    std::lock_guard lock(mutex_);
    return !poisoned_ && submitting_ == 0 && sealed_ && producer_.Complete();
  }
  bool Idle() const {
    std::lock_guard lock(mutex_);
    if (poisoned_ || submitting_ != 0 || (write_recorded_ && !sealed_)) return false;
    for (const auto& pending : pending_) if (pending.fence && !pending.Complete()) return false;
    return true;
  }
 private:
  mutable std::mutex mutex_;
  Ticket producer_;
  std::array<Ticket, 8> pending_;
  uint32_t submitting_ = 0;
  bool write_recorded_ = false, sealed_ = false, poisoned_ = false;
};
struct Use {
  std::shared_ptr<Lifetime> lifetime;
  bool write = false;
};
struct Recording {
  std::mutex mutex;
  std::array<Use, 16> uses;
  uint32_t count = 0;
  uint64_t observed = 0, submitted = 0;
  void Clear() {
    std::lock_guard lock(mutex);
    for (uint32_t i = 0; i < count; ++i) {
      if (observed != submitted) uses[i].lifetime->Poison();
      if (uses[i].write) uses[i].lifetime->Seal();
      uses[i] = {};
    }
    count = 0; observed = submitted = 0;
  }
};
struct Queue {
  device* owner = nullptr;
  std::mutex mutex;
  std::shared_ptr<Fence> fence = std::make_shared<Fence>();
  uint64_t sequence = 0;
};
struct __declspec(uuid("50153788-2b89-4dfb-9d0d-d5939842111c")) CommandData {
  std::shared_ptr<Recording> recording = std::make_shared<Recording>();
  ID3D12CommandList* native = nullptr;
};
inline std::mutex registry_mutex, install_mutex;
inline std::unordered_map<ID3D12CommandList*, std::shared_ptr<Recording>> recordings;
inline std::unordered_map<ID3D12CommandQueue*, std::shared_ptr<Queue>> queues;
using Execute = void(STDMETHODCALLTYPE*)(ID3D12CommandQueue*, UINT, ID3D12CommandList* const*);
inline Execute execute = nullptr;
inline void* target = nullptr;

inline void STDMETHODCALLTYPE ExecuteHook(ID3D12CommandQueue* native, UINT count, ID3D12CommandList* const* lists) {
  // Fixed storage keeps the submission callback free of heap allocation. The
  // water pool is bounded below this limit; overflow poisons its leases.
  std::array<Use, 16> uses;
  uint32_t used = 0;
  std::shared_ptr<Queue> queue;
  bool overflow = false;
  {
    std::lock_guard registry_lock(registry_mutex);
    if (const auto found = queues.find(native); found != queues.end()) queue = found->second;
    if (lists) for (UINT i = 0; i < count; ++i) {
      const auto found = recordings.find(lists[i]);
      if (found == recordings.end()) continue;
      std::lock_guard record_lock(found->second->mutex);
      for (uint32_t u = 0; u < found->second->count; ++u) {
        const auto& use = found->second->uses[u];
        uint32_t entry = 0;
        while (entry < used && uses[entry].lifetime != use.lifetime) ++entry;
        if (entry == used) {
          if (used == uses.size()) { use.lifetime->Poison(); overflow = true; continue; }
          uses[used++] = use;
          use.lifetime->BeginSubmission();
        } else uses[entry].write |= use.write;
      }
      // The native hook has seen this recording. Completion still comes only
      // from the post-Execute signal below, not the earlier ReShade event.
      found->second->submitted = found->second->observed;
    }
  }
  if (used == 0) { execute(native, count, lists); return; }
  if (!queue || overflow) {
    for (uint32_t i = 0; i < used; ++i) uses[i].lifetime->Poison();
    execute(native, count, lists); return;
  }
  std::lock_guard queue_lock(queue->mutex);
  execute(native, count, lists);
  // ID3D12CommandQueue::Signal is enqueued AFTER the actual submitted work.
  // Signals in ReShade's execute_command_list event would precede that work.
  if (queue->sequence == UINT64_MAX || FAILED(native->Signal(queue->fence->native.Get(), ++queue->sequence)))
    queue->fence->failed.store(true, std::memory_order_release);
  const Ticket completion{queue->fence, queue->sequence};
  for (uint32_t i = 0; i < used; ++i) uses[i].lifetime->Submitted(completion, uses[i].write);
}

inline bool Install(ID3D12CommandQueue* queue) {
  std::lock_guard lock(install_mutex);
  void* address = (*reinterpret_cast<void***>(queue))[10]; // ExecuteCommandLists.
  if (target) return target == address;
  execute = reinterpret_cast<Execute>(address);
  const std::array hooks{NativeHook{reinterpret_cast<void**>(&execute), reinterpret_cast<void*>(&ExecuteHook)}};
  if (!AttachNativeHooks(hooks, reinterpret_cast<const void*>(&Install))) return false;
  target = address;
  return true;
}
inline void OnQueue(command_queue* api_queue) {
  if (api_queue->get_device()->get_api() != device_api::d3d12) return;
  auto* native = reinterpret_cast<ID3D12CommandQueue*>(api_queue->get_native());
  renodx::utils::directx::NativeFromReShadeProxy(&native);
  ComPtr<ID3D12Device> device;
  if (FAILED(native->GetDevice(IID_PPV_ARGS(&device))) || !Install(native)) return;
  auto queue = std::make_shared<Queue>(); queue->owner = api_queue->get_device();
  if (FAILED(device->CreateFence(0, D3D12_FENCE_FLAG_NONE, IID_PPV_ARGS(&queue->fence->native)))) return;
  std::lock_guard lock(registry_mutex); queues[native] = std::move(queue);
}
inline void OnQueueDestroy(command_queue* api_queue) {
  auto* native = reinterpret_cast<ID3D12CommandQueue*>(api_queue->get_native());
  renodx::utils::directx::NativeFromReShadeProxy(&native);
  std::lock_guard lock(registry_mutex); queues.erase(native);
}
// ReShade may upgrade a closed native list's COM interface after creation.
// Keep every observed pointer attached to the stable API recording owner so
// the post-Execute fence sees the same leases as the pre-Execute callback.
inline void RefreshCommand(command_list* cmd, CommandData* data) {
  auto* native = reinterpret_cast<ID3D12CommandList*>(cmd->get_native());
  renodx::utils::directx::NativeFromReShadeProxy(&native);
  std::lock_guard lock(registry_mutex);
  data->native = native;
  recordings[native] = data->recording;
}
inline void OnCommand(command_list* cmd) {
  if (cmd->get_device()->get_api() != device_api::d3d12) return;
  RefreshCommand(cmd, renodx::utils::data::Create<CommandData>(cmd));
}
inline void OnReset(command_list* cmd) {
  if (auto* data = renodx::utils::data::Get<CommandData>(cmd)) {
    data->recording->Clear();
    RefreshCommand(cmd, data);
  }
}
inline void OnCommandDestroy(command_list* cmd) {
  auto* data = renodx::utils::data::Get<CommandData>(cmd);
  if (!data) return;
  data->recording->Clear();
  { std::lock_guard lock(registry_mutex);
    std::erase_if(recordings, [&](const auto& entry) { return entry.second == data->recording; }); }
  renodx::utils::data::Delete<CommandData>(cmd);
}
inline void OnExecute(command_queue* api_queue, command_list* cmd) {
  auto* data = renodx::utils::data::Get<CommandData>(cmd);
  if (!data) return;
  RefreshCommand(cmd, data);
  auto* native = reinterpret_cast<ID3D12CommandQueue*>(api_queue->get_native());
  renodx::utils::directx::NativeFromReShadeProxy(&native);
  bool tracked;
  { std::lock_guard lock(registry_mutex); tracked = queues.contains(native); }
  std::lock_guard lock(data->recording->mutex);
  ++data->recording->observed;
  if (!tracked) for (uint32_t i = 0; i < data->recording->count; ++i) data->recording->uses[i].lifetime->Poison();
}

inline bool Track(command_list* cmd, const std::shared_ptr<Lifetime>& lifetime, bool write) {
  auto* data = renodx::utils::data::Get<CommandData>(cmd);
  if (!data || !lifetime) return false;
  RefreshCommand(cmd, data);
  bool available = false;
  { std::lock_guard lock(registry_mutex);
    for (const auto& queue : queues) available |= queue.second->owner == cmd->get_device()
        && !queue.second->fence->failed.load(std::memory_order_acquire); }
  if (!available) return false;
  std::lock_guard lock(data->recording->mutex);
  for (uint32_t i = 0; i < data->recording->count; ++i)
    if (data->recording->uses[i].lifetime == lifetime) return data->recording->uses[i].write == write;
  if (data->recording->count == data->recording->uses.size()) return false;
  if (write ? !lifetime->RecordWrite() : !lifetime->Ready()) return false;
  data->recording->uses[data->recording->count++] = {lifetime, write};
  return true;
}
inline void UseRuntime(DWORD reason) {
  if (reason == DLL_PROCESS_ATTACH) {
    reshade::register_event<reshade::addon_event::init_command_queue>(OnQueue);
    reshade::register_event<reshade::addon_event::destroy_command_queue>(OnQueueDestroy);
    reshade::register_event<reshade::addon_event::init_command_list>(OnCommand);
    reshade::register_event<reshade::addon_event::reset_command_list>(OnReset);
    reshade::register_event<reshade::addon_event::destroy_command_list>(OnCommandDestroy);
    reshade::register_event<reshade::addon_event::execute_command_list>(OnExecute);
  } else if (reason == DLL_PROCESS_DETACH) {
    reshade::unregister_event<reshade::addon_event::execute_command_list>(OnExecute);
    reshade::unregister_event<reshade::addon_event::destroy_command_list>(OnCommandDestroy);
    reshade::unregister_event<reshade::addon_event::reset_command_list>(OnReset);
    reshade::unregister_event<reshade::addon_event::init_command_list>(OnCommand);
    reshade::unregister_event<reshade::addon_event::destroy_command_queue>(OnQueueDestroy);
    reshade::unregister_event<reshade::addon_event::init_command_queue>(OnQueue);
    std::lock_guard lock(registry_mutex); recordings.clear(); queues.clear();
  }
}
}  // namespace witcher3graphics::water::submission
