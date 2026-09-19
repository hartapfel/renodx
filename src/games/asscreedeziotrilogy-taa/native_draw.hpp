/*
 * Copyright (C) 2026 Hartapfel
 * SPDX-License-Identifier: MIT
 */
#pragma once
#include <windows.h>
#include <d3d9.h>
#include <wrl/client.h>
#include <cstdint>
#include <cstring>
#include <memory>
#include <mutex>
#include <unordered_map>
#include <unordered_set>

namespace acbrotherhood::native_draw {
// Native dispatch hooks shared by geometry capture and presentation. Draw calls
// still pass through ReShade's regular draw/shader callbacks.
struct Hook {
  void* original = nullptr;
  void* replacement = nullptr;
  std::unordered_set<void*> owners;
  bool installed = false;
};
inline std::mutex mutex;
inline std::unordered_map<void**, Hook> hooks;
struct ImmediateBuffers {
  IDirect3DDevice9* native = nullptr;  // Borrowed for the owning device lifetime.
  Microsoft::WRL::ComPtr<IDirect3DVertexBuffer9> vertices;
  Microsoft::WRL::ComPtr<IDirect3DIndexBuffer9> indices;
  UINT vertex_capacity = 0, index_capacity = 0;
  D3DFORMAT index_format = D3DFMT_UNKNOWN;
};
inline std::unordered_map<IDirect3DDevice9*, std::shared_ptr<ImmediateBuffers>> immediate_buffers;
inline thread_local unsigned immediate_draw_depth = 0;
inline void (*on_begin_scene)(IDirect3DDevice9*) = nullptr;
template <typename Function>
Function Original(void* object, size_t slot) {
  const std::lock_guard lock(mutex);
  return reinterpret_cast<Function>(hooks.at(*reinterpret_cast<void***>(object) + slot).original);
}

inline bool Install(void* object, size_t index, void* replacement, void* owner = nullptr) {
  const std::lock_guard lock(mutex);
  if (!owner) owner = object;
  auto** address = *reinterpret_cast<void***>(object) + index;
  auto& hook = hooks[address];
  if (hook.installed) {
    hook.owners.insert(owner);
    if (*address == hook.replacement) return true;
    // Reset can restore driver dispatch slots. Re-arm only a known original;
    // chaining an unfamiliar overlay hook here could recurse through us.
    if (*address != hook.original) return false;
  }
  DWORD protection;
  if (!VirtualProtect(address, sizeof(void*), PAGE_READWRITE, &protection)) return false;
  hook.original = *address;
  hook.replacement = replacement;
  hook.owners.insert(owner);
  hook.installed = true;
  InterlockedExchangePointer(reinterpret_cast<void* volatile*>(address), replacement);
  DWORD ignored;
  VirtualProtect(address, sizeof(void*), protection, &ignored);
  return true;
}

inline UINT PrimitiveVertices(D3DPRIMITIVETYPE topology, UINT primitives) {
  uint64_t count = 0;
  switch (topology) {
    case D3DPT_POINTLIST: count = primitives; break;
    case D3DPT_LINELIST: count = uint64_t(primitives) * 2; break;
    case D3DPT_LINESTRIP: count = uint64_t(primitives) + 1; break;
    case D3DPT_TRIANGLELIST: count = uint64_t(primitives) * 3; break;
    case D3DPT_TRIANGLESTRIP:
    case D3DPT_TRIANGLEFAN: count = uint64_t(primitives) + 2; break;
    default: return 0;
  }
  return count <= UINT_MAX ? UINT(count) : 0;
}

// ReShade's UP event emulation can retain freed temporary buffer handles after
// Reset. Bypass that uploader with small native dynamic buffers, then use the
// wrapper's ordinary Draw calls so both the TAA and HDR callbacks still run.
inline HRESULT DrawImmediate(IDirect3DDevice9* wrapper, D3DPRIMITIVETYPE topology, UINT minimum, UINT vertices,
                             UINT primitives, const void* index_data, D3DFORMAT format, const void* vertex_data, UINT stride) {
  std::shared_ptr<ImmediateBuffers> buffers;
  {
    const std::lock_guard lock(mutex);
    const auto found = immediate_buffers.find(wrapper);
    if (found == immediate_buffers.end()) return D3DERR_INVALIDCALL;
    buffers = found->second;
  }
  constexpr UINT MAX_UPLOAD = 16 * 1024 * 1024;
  const UINT count = PrimitiveVertices(topology, primitives);
  const UINT index_stride = format == D3DFMT_INDEX32 ? 4 : 2;
  const uint64_t vertex_bytes = uint64_t(vertices) * stride;
  const uint64_t index_bytes = index_data ? uint64_t(count) * index_stride : 0;
  if (!count || !vertex_data || !stride || !vertices || vertex_bytes > MAX_UPLOAD || index_bytes > MAX_UPLOAD
      || minimum > INT_MAX || uint64_t(minimum) * stride + vertex_bytes > SIZE_MAX
      || (index_data && format != D3DFMT_INDEX16 && format != D3DFMT_INDEX32)) return D3DERR_INVALIDCALL;
  if (vertex_bytes > buffers->vertex_capacity) {
    Microsoft::WRL::ComPtr<IDirect3DVertexBuffer9> replacement;
    const UINT capacity = (UINT(vertex_bytes) + 4095u) & ~4095u;
    const HRESULT result = buffers->native->CreateVertexBuffer(capacity, D3DUSAGE_DYNAMIC | D3DUSAGE_WRITEONLY, 0,
                                                               D3DPOOL_DEFAULT, &replacement, nullptr);
    if (FAILED(result)) return result;
    buffers->vertices = std::move(replacement);
    buffers->vertex_capacity = capacity;
  }
  if (index_data && (index_bytes > buffers->index_capacity || format != buffers->index_format)) {
    Microsoft::WRL::ComPtr<IDirect3DIndexBuffer9> replacement;
    const UINT capacity = (UINT(index_bytes) + 4095u) & ~4095u;
    const HRESULT result = buffers->native->CreateIndexBuffer(capacity, D3DUSAGE_DYNAMIC | D3DUSAGE_WRITEONLY, format,
                                                              D3DPOOL_DEFAULT, &replacement, nullptr);
    if (FAILED(result)) return result;
    buffers->indices = std::move(replacement);
    buffers->index_capacity = capacity;
    buffers->index_format = format;
  }
  void* mapped = nullptr;
  HRESULT result = buffers->vertices->Lock(0, UINT(vertex_bytes), &mapped, D3DLOCK_DISCARD);
  if (FAILED(result)) return result;
  std::memcpy(mapped, static_cast<const unsigned char*>(vertex_data) + size_t(minimum) * stride, size_t(vertex_bytes));
  if (FAILED(result = buffers->vertices->Unlock())) return result;
  if (index_data) {
    if (FAILED(result = buffers->indices->Lock(0, UINT(index_bytes), &mapped, D3DLOCK_DISCARD))) return result;
    std::memcpy(mapped, index_data, size_t(index_bytes));
    if (FAILED(result = buffers->indices->Unlock())) return result;
  }
  UINT frequency = 1;
  if (FAILED(result = wrapper->GetStreamSourceFreq(0, &frequency))) return result;
  if (FAILED(result = wrapper->SetStreamSourceFreq(0, 1))) return result;
  result = wrapper->SetStreamSource(0, buffers->vertices.Get(), 0, stride);
  if (SUCCEEDED(result) && index_data) result = wrapper->SetIndices(buffers->indices.Get());
  if (SUCCEEDED(result)) {
    ++immediate_draw_depth;
    result = index_data ? wrapper->DrawIndexedPrimitive(topology, -INT(minimum), minimum, vertices, 0, primitives)
                        : wrapper->DrawPrimitive(topology, 0, primitives);
    --immediate_draw_depth;
  }
  // Match native UP postconditions, including ReShade's tracked bindings.
  wrapper->SetStreamSource(0, nullptr, 0, 0);
  if (index_data) wrapper->SetIndices(nullptr);
  wrapper->SetStreamSourceFreq(0, frequency);
  return result;
}

inline HRESULT STDMETHODCALLTYPE DrawPrimitiveUP(IDirect3DDevice9* wrapper, D3DPRIMITIVETYPE topology, UINT primitives,
                                                 const void* vertices, UINT stride) {
  return DrawImmediate(wrapper, topology, 0, PrimitiveVertices(topology, primitives), primitives, nullptr, D3DFMT_UNKNOWN, vertices, stride);
}

inline HRESULT STDMETHODCALLTYPE DrawIndexedPrimitiveUP(IDirect3DDevice9* wrapper, D3DPRIMITIVETYPE topology,
                                                        UINT minimum, UINT count, UINT primitives, const void* indices,
                                                        D3DFORMAT format, const void* vertices, UINT stride) {
  if (!indices) return D3DERR_INVALIDCALL;
  return DrawImmediate(wrapper, topology, minimum, count, primitives, indices, format, vertices, stride);
}

inline HRESULT STDMETHODCALLTYPE BeginScene(IDirect3DDevice9* wrapper) {
  if (on_begin_scene) on_begin_scene(wrapper);
  return Original<decltype(&BeginScene)>(wrapper, 41)(wrapper);
}

inline bool InstallImmediate(IDirect3DDevice9* wrapper, IDirect3DDevice9* native) {
  {
    const std::lock_guard lock(mutex);
    auto& buffers = immediate_buffers[wrapper];
    if (!buffers) buffers = std::make_shared<ImmediateBuffers>();
    buffers->native = native;
  }
  return Install(wrapper, 41, reinterpret_cast<void*>(&BeginScene))
         && Install(wrapper, 83, reinterpret_cast<void*>(&DrawPrimitiveUP))
         && Install(wrapper, 84, reinterpret_cast<void*>(&DrawIndexedPrimitiveUP));
}

inline void ResetImmediate(IDirect3DDevice9* wrapper) {
  const std::lock_guard lock(mutex);
  if (const auto found = immediate_buffers.find(wrapper); found != immediate_buffers.end()) {
    auto* buffers = found->second.get();
    buffers->vertices.Reset();
    buffers->indices.Reset();
    buffers->vertex_capacity = buffers->index_capacity = 0;
    buffers->index_format = D3DFMT_UNKNOWN;
  }
}

// Device tables may live inside the device allocation; restore them before
// destruction. Shared wrapper tables stay hooked until their last owner leaves.
inline void Uninstall(void* object = nullptr) {
  const std::lock_guard lock(mutex);
  if (object) immediate_buffers.erase(static_cast<IDirect3DDevice9*>(object));
  else immediate_buffers.clear();
  for (auto& [address, hook] : hooks) {
    if (!hook.installed) continue;
    if (object != nullptr && (hook.owners.erase(object) == 0 || !hook.owners.empty())) continue;
    DWORD protection;
    if (!VirtualProtect(address, sizeof(void*), PAGE_READWRITE, &protection)) continue;
    InterlockedCompareExchangePointer(reinterpret_cast<void* volatile*>(address), hook.original, hook.replacement);
    DWORD ignored;
    VirtualProtect(address, sizeof(void*), protection, &ignored);
    hook.installed = false;
    hook.owners.clear();
    // Retain the original for calls already entering this hook on another thread.
  }
}

}  // namespace acbrotherhood::native_draw
