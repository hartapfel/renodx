/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#pragma once
#include <d3d11.h>
#include <wrl/client.h>
#include <cstdint>
#include <atomic>
#include <cstring>
#include <mutex>
#include <unordered_map>
#include <vector>

namespace witcher3classic::temporal {
// Mirror only CBs actually requested by motion history. Never read mapped
// write-combined memory: redirect full DISCARD writes to ordinary CPU memory,
// then copy them back before the native Unmap. Unknown/GPU writes invalidate
// the mirror and retain the proven GPU-copy fallback.
class ConstantUploads {
 public:
  uint32_t uploaded = 0, copied = 0, unchanged = 0;
  // Enable only after all mutation/invalidation callbacks are installed.
  std::atomic<bool> track_writes = false;

  void Snapshot(ID3D11DeviceContext* context, ID3D11Buffer* destination, ID3D11Buffer* source, uint64_t frame) {
    std::lock_guard lock(mutex_);
    if (counted_frame_ != frame) {
      uploaded = copied = unchanged = 0;
      counted_frame_ = frame;
    }
    if (!track_writes) { context->CopyResource(destination, source); ++copied; return; }
    auto found = entries_.find(source);
    if (found == entries_.end()) {
      if (entries_.size() >= 2048) { context->CopyResource(destination, source); ++copied; return; }
      D3D11_BUFFER_DESC desc;
      source->GetDesc(&desc);
      if (desc.BindFlags != D3D11_BIND_CONSTANT_BUFFER || !desc.ByteWidth || desc.ByteWidth > 65536) {
        context->CopyResource(destination, source); ++copied; return;
      }
      found = entries_.try_emplace(source).first;
      found->second.source = source;
      found->second.bytes.resize(desc.ByteWidth);
    }
    auto& entry = found->second;
    entry.used = frame;
    if (targets_.size() >= 4096 && !targets_.contains(destination)) targets_.clear();
    auto& target = targets_[destination];
    target.used = frame;
    if (target.source.Get() == source && target.version == entry.version) { ++unchanged; return; }
    target.buffer = destination; // Prevent recycled COM addresses matching old versions.
    target.source = source;
    D3D11_MAPPED_SUBRESOURCE mapped = {};
    if (entry.valid && !entry.mapping && SUCCEEDED(context->Map(destination, 0, D3D11_MAP_WRITE_DISCARD, 0, &mapped))) {
      std::memcpy(mapped.pData, entry.bytes.data(), entry.bytes.size());
      context->Unmap(destination, 0);
      ++uploaded;
    } else {
      context->CopyResource(destination, source);
      ++copied;
    }
    target.version = entry.version;
  }

  void Map(ID3D11Buffer* source, uint64_t offset, uint64_t size, bool discard, void** data) {
    if (!track_writes.load(std::memory_order_relaxed)) return;
    std::lock_guard lock(mutex_);
    const auto found = entries_.find(source);
    if (found == entries_.end()) return;
    auto& entry = found->second;
    entry.valid = false;
    ++entry.version;
    if (discard && offset == 0 && (size == UINT64_MAX || size == entry.bytes.size()) && data && *data && !entry.mapping) {
      entry.mapping = *data;
      *data = entry.bytes.data();
    }
  }
  void Unmap(ID3D11Buffer* source) {
    std::lock_guard lock(mutex_);
    const auto found = entries_.find(source);
    if (found == entries_.end() || !found->second.mapping) return;
    auto& entry = found->second;
    std::memcpy(entry.mapping, entry.bytes.data(), entry.bytes.size());
    entry.mapping = nullptr;
    entry.valid = true;
  }
  void Update(ID3D11Buffer* source, const void* data, uint64_t offset, uint64_t size) {
    std::lock_guard lock(mutex_);
    const auto found = entries_.find(source);
    if (found == entries_.end()) return;
    auto& entry = found->second;
    ++entry.version;
    if (size == UINT64_MAX && offset == 0) size = entry.bytes.size();
    if (!data || entry.mapping || offset > entry.bytes.size() || size > entry.bytes.size() - offset) {
      entry.valid = false;
      return;
    }
    if (offset == 0 && size == entry.bytes.size()) entry.valid = true;
    if (entry.valid) std::memcpy(entry.bytes.data() + offset, data, size_t(size));
  }
  void Invalidate(ID3D11Buffer* source = nullptr) {
    std::lock_guard lock(mutex_);
    if (source) {
      const auto found = entries_.find(source);
      if (found == entries_.end()) return;
      found->second.valid = false;
      ++found->second.version;
    } else {
      for (auto& [_, entry] : entries_) { entry.valid = false; ++entry.version; }
    }
  }
  void Finish(uint64_t frame) {
    std::lock_guard lock(mutex_);
    for (auto it = entries_.begin(); it != entries_.end();) {
      if (!it->second.mapping && frame > it->second.used + 120) it = entries_.erase(it);
      else ++it;
    }
    for (auto it = targets_.begin(); it != targets_.end();) {
      if (frame > it->second.used + 120) it = targets_.erase(it);
      else ++it;
    }
  }

 private:
  struct Target {
    Microsoft::WRL::ComPtr<ID3D11Buffer> buffer, source;
    uint64_t version = 0, used = 0;
  };
  struct Entry {
    Microsoft::WRL::ComPtr<ID3D11Buffer> source;
    std::vector<uint8_t> bytes;
    uint64_t version = 1, used = 0;
    void* mapping = nullptr;
    bool valid = false;
  };
  std::mutex mutex_;
  std::unordered_map<ID3D11Buffer*, Entry> entries_;
  std::unordered_map<ID3D11Buffer*, Target> targets_;
  uint64_t counted_frame_ = UINT64_MAX;
};
}  // namespace witcher3classic::temporal
