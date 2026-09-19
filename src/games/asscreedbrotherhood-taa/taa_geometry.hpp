/*
 * Copyright (C) 2026 Hartapfel
 * SPDX-License-Identifier: MIT
 */
#pragma once

#include <atomic>
#include <algorithm>
#include <array>
#include <cstdint>
#include <cstring>
#include <memory>
#include <mutex>
#include <unordered_map>
#include <vector>
#include <d3d9.h>
#include <wrl/client.h>

namespace acbrotherhood::taa {

// Recycle only snapshots whose CPU owners have released them. A DISCARD lock
// lets DX9 retain any storage still read by queued GPU draws, without a query
// wait or creating a new driver resource for every cloth upload.
struct GeometryUploadPool {
  struct Buffer {
    Microsoft::WRL::ComPtr<IDirect3DVertexBuffer9> vertices;
    UINT bytes = 0;
  };
  std::mutex mutex;
  std::array<Buffer, 64> free;
  size_t cached_bytes = 0;
  size_t recycle_cursor = 0;
  uint64_t created = 0, reused = 0;

  HRESULT Acquire(IDirect3DDevice9* native, UINT bytes, Microsoft::WRL::ComPtr<IDirect3DVertexBuffer9>* vertices) {
    {
      const std::scoped_lock lock(mutex);
      // Exact sizes preserve the existing live-snapshot memory accounting.
      // Character meshes normally retain their vertex count between poses.
      for (auto& buffer : free) if (buffer.vertices && buffer.bytes == bytes) {
        *vertices = std::move(buffer.vertices);
        buffer.bytes = 0;
        cached_bytes -= bytes;
        ++reused;
        return S_OK;
      }
    }
    const HRESULT result = native->CreateVertexBuffer(bytes, D3DUSAGE_DYNAMIC | D3DUSAGE_WRITEONLY,
                                                       0, D3DPOOL_DEFAULT, vertices->ReleaseAndGetAddressOf(), nullptr);
    if (SUCCEEDED(result)) { const std::scoped_lock lock(mutex); ++created; }
    return result;
  }

  void Recycle(Microsoft::WRL::ComPtr<IDirect3DVertexBuffer9>* vertices, UINT bytes) {
    if (!*vertices || bytes > 4 * 1024 * 1024) return;
    const std::scoped_lock lock(mutex);
    // Replace older cached sizes as the scene changes; a full cache must not
    // permanently retain the first scene's meshes and miss every later pose.
    for (;;) {
      auto& buffer = free[recycle_cursor];
      recycle_cursor = (recycle_cursor + 1) % free.size();
      cached_bytes -= buffer.bytes;
      buffer = {};
      if (cached_bytes + bytes <= 4 * 1024 * 1024) {
        buffer.vertices = std::move(*vertices);
        buffer.bytes = bytes;
        cached_bytes += bytes;
        return;
      }
    }
  }
};

struct GeometrySnapshot {
  Microsoft::WRL::ComPtr<IDirect3DVertexBuffer9> vertices;
  // Retain exact bytes to recognize duplicate material submissions even when
  // the game uploads the same cloth pose again at another ring-buffer offset.
  std::vector<unsigned char> data;
  std::shared_ptr<std::atomic_size_t> allocation;
  std::shared_ptr<GeometryUploadPool> pool;
  size_t bytes = 0;
  UINT offset = 0;
  ~GeometrySnapshot() {
    if (allocation) allocation->fetch_sub(bytes);
    if (pool) pool->Recycle(std::addressof(vertices), UINT(bytes));
  }
};

// Copy mutable vertices while the game still owns a valid CPU mapping. Never
// read back a WRITEONLY GPU buffer or retain a pointer after its Unlock call.
// Each draw retains an immutable GPU snapshot for current/previous animation.
struct GeometryCache {
  static constexpr UINT PAGE_SIZE = 4096;
  struct Buffer {
    std::vector<std::unique_ptr<std::array<unsigned char, PAGE_SIZE>>> pages;
    UINT capacity = 0;
    size_t allocated_bytes = 0;
    void* mapping = nullptr;
    void* upload_mapping = nullptr;
    std::unique_ptr<unsigned char[]> upload_shadow;
    UINT upload_capacity = 0;
    UINT offset = 0, size = 0;
    unsigned frame = 0;
    std::vector<std::pair<UINT, UINT>> valid_ranges;
    std::vector<std::weak_ptr<GeometrySnapshot>> snapshots;
  };
  std::mutex mutex;
  std::unordered_map<uintptr_t, Buffer> buffers;
  std::shared_ptr<std::atomic_size_t> gpu_bytes = std::make_shared<std::atomic_size_t>(0);
  std::shared_ptr<GeometryUploadPool> uploads = std::make_shared<GeometryUploadPool>();
  size_t cpu_bytes = 0;
  size_t upload_bytes = 0;
  uint64_t redirected_upload_bytes = 0, direct_capture_bytes = 0;
  unsigned frame = 0;

  void Map(IDirect3DVertexBuffer9* vertices, UINT offset, UINT size, void* mapping, bool discard, void** redirected_mapping = nullptr) {
    D3DVERTEXBUFFER_DESC desc;
    if (!mapping || FAILED(vertices->GetDesc(&desc)) || !(desc.Usage & D3DUSAGE_DYNAMIC)
        || !desc.Size || desc.Size > 4 * 1024 * 1024 || offset >= desc.Size) return;
    if (size == 0 || size == UINT_MAX) size = desc.Size - offset;
    if (size > desc.Size - offset) return;
    std::scoped_lock lock(mutex);
    const uintptr_t key = reinterpret_cast<uintptr_t>(vertices);
    auto found = buffers.find(key);
    if (found == buffers.end()) {
      if (buffers.size() >= 128) return;
      found = buffers.emplace(key, Buffer{}).first;
      found->second.capacity = desc.Size;
      found->second.pages.resize((desc.Size + PAGE_SIZE - 1) / PAGE_SIZE);
    }
    auto& buffer = found->second;
    if (buffer.capacity != desc.Size) return;
    buffer.mapping = nullptr;
    buffer.upload_mapping = nullptr;
    buffer.offset = offset;
    buffer.size = size;
    buffer.frame = frame;
    buffer.snapshots.clear();
    if (discard) {
      buffer.valid_ranges.clear();
      for (auto& page : buffer.pages) page.reset();
      cpu_bytes -= buffer.allocated_bytes;
      buffer.allocated_bytes = 0;
    }
    // Native cloth rotates several large buffers, but uploads only small
    // ranges. Charging their unused capacity would evict alternating frames.
    const UINT last_page = (offset + size - 1) / PAGE_SIZE;
    size_t needed = 0;
    for (UINT page = offset / PAGE_SIZE; page <= last_page; ++page) if (!buffer.pages[page]) needed += PAGE_SIZE;
    if (cpu_bytes + gpu_bytes->load() + needed > 8 * 1024 * 1024) {
      // This write was not captured: no old bytes from this buffer are valid.
      buffer.valid_ranges.clear();
      return;
    }
    for (UINT page = offset / PAGE_SIZE; page <= last_page; ++page) {
      if (!buffer.pages[page]) buffer.pages[page] = std::make_unique<std::array<unsigned char, PAGE_SIZE>>();
    }
    cpu_bytes += needed;
    buffer.allocated_bytes += needed;
    buffer.mapping = mapping;
    // Reading a driver upload mapping can be much slower than writing it.
    // DISCARD makes old contents undefined. Other locks may modify only part
    // of their range: redirect only when every old byte is already captured,
    // and seed the shadow so application reads and untouched bytes survive.
    bool known_range = discard;
    if (redirected_mapping && !discard) {
      for (const auto& range : buffer.valid_ranges)
        if (offset >= range.first && offset + size <= range.second) { known_range = true; break; }
    }
    if (redirected_mapping && known_range && (desc.Usage & D3DUSAGE_WRITEONLY)
        && upload_bytes - buffer.upload_capacity + size <= 4 * 1024 * 1024) {
      if (buffer.upload_capacity < size) {
        buffer.upload_shadow = std::make_unique<unsigned char[]>(size);
        upload_bytes += size - buffer.upload_capacity;
        buffer.upload_capacity = size;
      }
      if (!discard) {
        for (UINT copied = 0; copied < size;) {
          const UINT source = offset + copied;
          const UINT count = std::min(size - copied, PAGE_SIZE - source % PAGE_SIZE);
          std::memcpy(buffer.upload_shadow.get() + copied,
                      buffer.pages[source / PAGE_SIZE]->data() + source % PAGE_SIZE, count);
          copied += count;
        }
      }
      buffer.upload_mapping = mapping;
      buffer.mapping = buffer.upload_shadow.get();
      *redirected_mapping = buffer.mapping;
    }
  }

  void Unmap(uintptr_t vertices) {
    std::scoped_lock lock(mutex);
    auto found = buffers.find(vertices);
    if (found == buffers.end() || !found->second.mapping) return;
    auto& buffer = found->second;
    if (buffer.upload_mapping) {
      std::memcpy(buffer.upload_mapping, buffer.mapping, buffer.size);
      buffer.upload_mapping = nullptr;
      redirected_upload_bytes += buffer.size;
    } else direct_capture_bytes += buffer.size;
    for (UINT copied = 0; copied < buffer.size;) {
      const UINT offset = buffer.offset + copied;
      const UINT count = std::min(buffer.size - copied, PAGE_SIZE - offset % PAGE_SIZE);
      std::memcpy(buffer.pages[offset / PAGE_SIZE]->data() + offset % PAGE_SIZE,
                  static_cast<const unsigned char*>(buffer.mapping) + copied, count);
      copied += count;
    }
    UINT begin = buffer.offset, end = begin + buffer.size;
    auto range = buffer.valid_ranges.begin();
    while (range != buffer.valid_ranges.end() && range->second < begin) ++range;
    while (range != buffer.valid_ranges.end() && range->first <= end) {
      begin = std::min(begin, range->first);
      end = std::max(end, range->second);
      range = buffer.valid_ranges.erase(range);
    }
    if (buffer.valid_ranges.size() < 512) buffer.valid_ranges.insert(range, {begin, end});
    buffer.mapping = nullptr;
  }

  std::shared_ptr<GeometrySnapshot> Snapshot(IDirect3DDevice9* native, IDirect3DVertexBuffer9* vertices, UINT offset = 0, UINT size = 0) {
    std::scoped_lock lock(mutex);
    auto found = buffers.find(reinterpret_cast<uintptr_t>(vertices));
    if (found == buffers.end() || found->second.mapping) return {};
    auto& buffer = found->second;
    if (offset >= buffer.capacity) return {};
    if (!size) size = buffer.capacity - offset;
    if (size > buffer.capacity - offset) return {};
    bool valid = false;
    for (const auto& range : buffer.valid_ranges) if (offset >= range.first && offset + size <= range.second) { valid = true; break; }
    if (!valid) return {};
    buffer.frame = frame;
    for (auto entry = buffer.snapshots.begin(); entry != buffer.snapshots.end();) {
      if (auto snapshot = entry->lock()) {
        if (snapshot->offset == offset && snapshot->bytes == size) return snapshot;
        ++entry;
      } else entry = buffer.snapshots.erase(entry);
    }
    if (gpu_bytes->load() + size > 16 * 1024 * 1024
        || cpu_bytes + gpu_bytes->load() + size > 8 * 1024 * 1024) return {};
    auto snapshot = std::make_shared<GeometrySnapshot>();
    snapshot->data.resize(size);
    if (FAILED(uploads->Acquire(native, size, std::addressof(snapshot->vertices)))) return {};
    void* destination = nullptr;
    if (FAILED(snapshot->vertices->Lock(0, 0, &destination, D3DLOCK_DISCARD))) return {};
    for (UINT copied = 0; copied < size;) {
      const UINT source = offset + copied;
      const UINT count = std::min(size - copied, PAGE_SIZE - source % PAGE_SIZE);
      std::memcpy(snapshot->data.data() + copied,
                  buffer.pages[source / PAGE_SIZE]->data() + source % PAGE_SIZE, count);
      copied += count;
    }
    std::memcpy(destination, snapshot->data.data(), size);
    if (FAILED(snapshot->vertices->Unlock())) return {};
    snapshot->allocation = gpu_bytes;
    snapshot->pool = uploads;
    snapshot->bytes = size;
    snapshot->offset = offset;
    gpu_bytes->fetch_add(snapshot->bytes);
    buffer.snapshots.push_back(snapshot);
    return snapshot;
  }

  void Retire(uintptr_t vertices = 0) {
    std::scoped_lock lock(mutex);
    if (!vertices) ++frame;
    for (auto i = buffers.begin(); i != buffers.end();) {
      if ((vertices && i->first == vertices) || (!vertices && !i->second.mapping && frame - i->second.frame > 3)) {
        cpu_bytes -= i->second.allocated_bytes;
        upload_bytes -= i->second.upload_capacity;
        i = buffers.erase(i);
      } else ++i;
    }
  }
};
}  // namespace acbrotherhood::taa
