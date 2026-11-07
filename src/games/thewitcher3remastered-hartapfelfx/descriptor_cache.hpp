// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#pragma once

#include <array>
#include <atomic>
#include <memory>
#include <shared_mutex>
#include <unordered_map>
#include <d3d12.h>
#include "../../utils/descriptor.hpp"

namespace hartapfelfx::descriptors {
namespace api = reshade::api;
using Value = renodx::utils::descriptor::DescriptorHeapSlot;

// Descriptor copies on independent recording workers must not take a shared
// exclusive device lock. Retain only descriptor metadata, never GPU resources.
// Atomic words make a reader racing a descriptor rewrite well-defined in C++.
struct Slot {
  std::atomic_uint64_t sequence{0};
  std::array<std::atomic_uint64_t, 4> words{};

  Value Read() const {
    for (unsigned attempt = 0; attempt < 32; ++attempt) {
      const uint64_t before = sequence.load(std::memory_order_acquire);
      if (before & 1) continue;
      std::array<uint64_t, 4> snapshot{};
      for (size_t index = 0; index < words.size(); ++index) {
        snapshot[index] = words[index].load(std::memory_order_relaxed);
      }
      std::atomic_thread_fence(std::memory_order_acquire);
      if (before == sequence.load(std::memory_order_relaxed)) {
        Value value;
        value.type = api::descriptor_type(snapshot[0]);
        if (value.type == api::descriptor_type::constant_buffer || value.type == api::descriptor_type::shader_storage_buffer) {
          value.buffer_range = {{snapshot[1]}, snapshot[2], snapshot[3]};
        } else {
          value.resource_view = {snapshot[1]};
        }
        return value;
      }
    }
    return {};
  }

  void Write(const Value& value) {
    uint64_t before = sequence.load(std::memory_order_relaxed);
    while ((before & 1) || !sequence.compare_exchange_weak(
        before, before + 1, std::memory_order_acquire, std::memory_order_relaxed)) {
      before = sequence.load(std::memory_order_relaxed);
    }
    std::atomic_thread_fence(std::memory_order_release);
    std::array<uint64_t, 4> snapshot{uint64_t(value.type)};
    if (value.type == api::descriptor_type::constant_buffer || value.type == api::descriptor_type::shader_storage_buffer) {
      snapshot[1] = value.buffer_range.buffer.handle;
      snapshot[2] = value.buffer_range.offset;
      snapshot[3] = value.buffer_range.size;
    } else {
      snapshot[1] = value.resource_view.handle;
    }
    for (size_t index = 0; index < words.size(); ++index) {
      words[index].store(snapshot[index], std::memory_order_relaxed);
    }
    sequence.store(before + 2, std::memory_order_release);
  }
};
static_assert(std::atomic_uint64_t::is_always_lock_free);

struct Heap {
  uint32_t count = 0;
  std::unique_ptr<Slot[]> slots;
};
struct Directory {
  std::shared_mutex mutex;
  std::unordered_map<uint64_t, std::shared_ptr<Heap>> heaps;
  std::atomic_uint64_t revision{0};
};
inline std::atomic_uint64_t next_generation{0};
struct __declspec(uuid("df1c681c-c697-49f4-9c08-d25f01bc3008")) DeviceData {
  std::shared_ptr<Directory> directory = std::make_shared<Directory>();
  const uint64_t generation = ++next_generation;
};
// The native heap owns this notification. No extra reference retains the
// game's heap, and its metadata disappears when the engine destroys it.
struct __declspec(uuid("9ce478a2-fb2b-4e19-adba-6bcb8d0d585f")) HeapLifetime : IUnknown {
  std::atomic_ulong references{1};
  std::weak_ptr<Directory> directory;
  uint64_t handle = 0;

  HRESULT STDMETHODCALLTYPE QueryInterface(REFIID iid, void** output) override {
    if (!output) return E_POINTER;
    *output = nullptr;
    if (iid != __uuidof(IUnknown)) return E_NOINTERFACE;
    *output = static_cast<IUnknown*>(this);
    AddRef();
    return S_OK;
  }
  ULONG STDMETHODCALLTYPE AddRef() override { return ++references; }
  ULONG STDMETHODCALLTYPE Release() override {
    const ULONG remaining = --references;
    if (remaining == 0) {
      if (auto owner = directory.lock()) {
        std::unique_lock lock(owner->mutex);
        owner->heaps.erase(handle);
        ++owner->revision;
      }
      delete this;
    }
    return remaining;
  }
};

inline Heap* Find(api::device* device, DeviceData* data, api::descriptor_table table,
                  uint32_t binding, uint32_t* offset) {
  if (!table.handle) return nullptr;
  api::descriptor_heap handle{};
  device->get_descriptor_heap_offset(table, binding, 0, &handle, offset);
  if (!handle.handle) return nullptr;
  struct Cached {
    uint64_t generation = 0, revision = 0, handle = 0;
    std::shared_ptr<Heap> heap;
  };
  static thread_local std::array<Cached, 8> cached;
  static thread_local unsigned cursor = 0;
  auto& directory = *data->directory;
  const uint64_t revision = directory.revision.load(std::memory_order_acquire);
  for (const auto& entry : cached) {
    if (entry.generation == data->generation && entry.revision == revision && entry.handle == handle.handle) return entry.heap.get();
  }
  std::shared_ptr<Heap> heap;
  {
    std::shared_lock lock(directory.mutex);
    if (const auto entry = directory.heaps.find(handle.handle); entry != directory.heaps.end()) {
      heap = entry->second;
    }
  }
  if (!heap) {
    const auto desc = reinterpret_cast<ID3D12DescriptorHeap*>(handle.handle)->GetDesc();
    // Samplers carry no pass input identity and need no shadow storage.
    if (desc.Type != D3D12_DESCRIPTOR_HEAP_TYPE_CBV_SRV_UAV) return nullptr;
    std::unique_lock lock(directory.mutex);
    auto& entry = directory.heaps[handle.handle];
    if (!entry) {
      entry = std::make_shared<Heap>();
      entry->count = desc.NumDescriptors;
      entry->slots = std::make_unique<Slot[]>(desc.NumDescriptors);
      auto* lifetime = new HeapLifetime();
      lifetime->directory = data->directory;
      lifetime->handle = handle.handle;
      const auto attached = reinterpret_cast<ID3D12DescriptorHeap*>(handle.handle)->SetPrivateDataInterface(
          __uuidof(HeapLifetime), lifetime);
      if (FAILED(attached)) {
        directory.heaps.erase(handle.handle);
        // Release after dropping the directory lock used by the notification.
        lock.unlock();
        lifetime->Release();
        return nullptr;
      }
      lifetime->Release();
    }
    heap = entry;
  }
  auto& entry = cached[cursor++ % cached.size()];
  entry = {data->generation, revision, handle.handle, std::move(heap)};
  return entry.heap.get();
}

inline Value Read(api::device* device, api::descriptor_table table, uint32_t binding) {
  auto* data = renodx::utils::data::Get<DeviceData>(device);
  if (!data) return {};
  uint32_t offset = 0;
  const auto* heap = Find(device, data, table, binding, &offset);
  if (!heap || offset >= heap->count) return {};
  return heap->slots[offset].Read();
}

inline bool OnUpdate(api::device* device, uint32_t count, const api::descriptor_table_update* updates) {
  auto* data = renodx::utils::data::Get<DeviceData>(device);
  if (!data) return false;
  for (uint32_t index = 0; index < count; ++index) {
    const auto& update = updates[index];
    if (update.type == api::descriptor_type::sampler || !update.count || !update.descriptors) continue;
    uint32_t offset = 0;
    auto* heap = Find(device, data, update.table, update.binding + update.array_offset, &offset);
    if (!heap || offset >= heap->count || update.count > heap->count - offset) continue;
    for (uint32_t item = 0; item < update.count; ++item) {
      Value value;
      value.type = update.type;
      if (update.type == api::descriptor_type::constant_buffer || update.type == api::descriptor_type::shader_storage_buffer) {
        value.buffer_range = static_cast<const api::buffer_range*>(update.descriptors)[item];
      } else if (update.type == api::descriptor_type::sampler_with_resource_view) {
        value.resource_view = static_cast<const api::sampler_with_resource_view*>(update.descriptors)[item].view;
      } else if (value.HasResourceView()) {
        value.resource_view = static_cast<const api::resource_view*>(update.descriptors)[item];
      }
      heap->slots[offset + item].Write(value);
    }
  }
  return false;
}

inline bool OnCopy(api::device* device, uint32_t count, const api::descriptor_table_copy* copies) {
  auto* data = renodx::utils::data::Get<DeviceData>(device);
  if (!data) return false;
  for (uint32_t index = 0; index < count; ++index) {
    const auto& copy = copies[index];
    if (!copy.count) continue;
    uint32_t source_offset = 0, dest_offset = 0;
    const auto* source = Find(device, data, copy.source_table, copy.source_binding + copy.source_array_offset, &source_offset);
    if (!source) continue;
    auto* dest = Find(device, data, copy.dest_table, copy.dest_binding + copy.dest_array_offset, &dest_offset);
    if (!dest || source_offset >= source->count || copy.count > source->count - source_offset
        || dest_offset >= dest->count || copy.count > dest->count - dest_offset) continue;
    for (uint32_t item = 0; item < copy.count; ++item) {
      dest->slots[dest_offset + item].Write(source->slots[source_offset + item].Read());
    }
  }
  return false;
}

inline void OnInit(api::device* device) {
  if (device->get_api() == api::device_api::d3d12) {
    renodx::utils::data::Create<DeviceData>(device);
  }
}
inline void OnDestroy(api::device* device) { renodx::utils::data::Delete<DeviceData>(device); }
inline void Use(DWORD reason) {
  if (reason == DLL_PROCESS_ATTACH) {
    reshade::register_event<reshade::addon_event::init_device>(OnInit);
    reshade::register_event<reshade::addon_event::destroy_device>(OnDestroy);
    reshade::register_event<reshade::addon_event::update_descriptor_tables>(OnUpdate);
    reshade::register_event<reshade::addon_event::copy_descriptor_tables>(OnCopy);
  } else if (reason == DLL_PROCESS_DETACH) {
    reshade::unregister_event<reshade::addon_event::init_device>(OnInit);
    reshade::unregister_event<reshade::addon_event::destroy_device>(OnDestroy);
    reshade::unregister_event<reshade::addon_event::update_descriptor_tables>(OnUpdate);
    reshade::unregister_event<reshade::addon_event::copy_descriptor_tables>(OnCopy);
  }
}
}  // namespace hartapfelfx::descriptors
