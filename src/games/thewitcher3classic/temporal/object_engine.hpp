/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#pragma once
#include <detours.h>
#include <tlhelp32.h>
#include <windows.h>
#include <atomic>
#include <cmath>
#include <cstring>
#include <mutex>
#include "./camera.hpp"
#include "./object_history.hpp"
#include "./rigid_history.hpp"
#include "./swarm_history.hpp"
#include "./upscale_engine.hpp"

namespace witcher3classic::temporal::object_engine {
// Process lifetime: native hooks may run during engine teardown after ReShade
// has destroyed its device. No GPU objects or ReShade calls live in this state.
struct State {
  ObjectHistory history;
  RigidHistory rigid_history;
  SwarmHistory swarm_history;
  std::unordered_map<uintptr_t, uint64_t> deformed_generations;
  uint64_t next_deformed_generation = 0;
  std::mutex mutex;
  std::atomic<bool> enabled = false;
  std::atomic<uint64_t> frame = 0;
  uintptr_t registry_address = 0;
  uintptr_t image = 0;
  bool installed = false;
};
inline State* state = new State;
inline thread_local uintptr_t deformed_owner = 0;
inline thread_local uint64_t deformed_generation = 0;
inline thread_local uintptr_t direct_object = 0;
inline thread_local uintptr_t direct_mesh = 0;
struct Batch {
  const float* instances = nullptr;
  uint32_t count = 0, stride = 0;
  std::span<const ObjectPose> previous;
};
inline thread_local Batch batch;
// Parallel to the engine's 64/80-byte CPU packing arrays. Indexing happens
// before their upload into the rotating IA ring; GPU offsets are never IDs.
struct NativeBatch {
  uintptr_t renderer = 0, mesh = 0;
  uint64_t frame = UINT64_MAX;
  std::vector<ObjectPose> previous;
};
inline thread_local std::array<NativeBatch, 2> native_batches;
struct SwarmInstance {
  const float* data;
  uintptr_t owner, group;
  uint32_t count, slot;
  bool instanced;
};
struct SwarmScope {
  std::vector<SwarmInstance> instances;
  std::vector<ObjectPose> pending;
  size_t next = 0;
  bool valid = false;
};
inline thread_local SwarmScope swarm_scratch;
inline thread_local SwarmScope* swarm_scope = nullptr;
inline thread_local std::span<const ObjectPose> swarm_batch;
using ObjectFreeFunction = void(__fastcall*)(uintptr_t);
inline ObjectFreeFunction object_free_function = nullptr;
using InstanceFunction = void(__fastcall*)(uint32_t, uintptr_t);
using FreeFunction = void(__fastcall*)(uintptr_t, uintptr_t);
using DeformedFunction = void(__fastcall*)(uintptr_t, uintptr_t, uintptr_t);
using BatchFunction = void(__fastcall*)(uintptr_t, uintptr_t, uint32_t, const float*, uint32_t, uint32_t, uintptr_t);
using SwarmFunction = uintptr_t(__fastcall*)(uintptr_t, uintptr_t, uintptr_t, uintptr_t, uintptr_t, uint32_t, uintptr_t, uintptr_t, uintptr_t);
using EulerFunction = void(__fastcall*)(const float*, float*);
using DrawFunction = void(__fastcall*)(uintptr_t, uint32_t, uintptr_t, uint32_t, uintptr_t);
inline InstanceFunction instance_function = nullptr;
inline FreeFunction free_function = nullptr;
inline DeformedFunction deformed_function = nullptr;
inline BatchFunction batch_function = nullptr;
inline SwarmFunction swarm_function = nullptr;
inline EulerFunction euler_function = nullptr;
inline DrawFunction draw_function = nullptr;

inline uintptr_t __fastcall SwarmHook(uintptr_t renderer, uintptr_t view, uintptr_t frame, uintptr_t material, uintptr_t mesh,
                                     uint32_t part, uintptr_t layout, uintptr_t nodes, uintptr_t options) {
  if (!state->enabled.load(std::memory_order_relaxed))
    return swarm_function(renderer, view, frame, material, mesh, part, layout, nodes, options);
  const auto previous = swarm_scope;
  if (previous) {
    // Unexpected recursion cannot borrow the outer draw's instance sequence.
    previous->valid = false;
    swarm_scope = nullptr;
    const auto result = swarm_function(renderer, view, frame, material, mesh, part, layout, nodes, options);
    swarm_scope = previous;
    return result;
  }
  auto& scope = swarm_scratch;
  scope.instances.clear();
  scope.pending.clear();
  scope.next = 0;
  scope.valid = true;
  uint32_t node_count = 0;
  for (auto node = nodes; node && scope.valid; node = *reinterpret_cast<const uintptr_t*>(node + 0x28)) {
    if (++node_count > 1024) { scope.valid = false; break; }
    const auto owner = *reinterpret_cast<const uintptr_t*>(node + 0x10);
    if (!owner || *reinterpret_cast<const uint32_t*>(owner + 0x10) != 14) continue;
    if (*reinterpret_cast<const uintptr_t*>(owner) != state->image + 0x2154338) { scope.valid = false; break; }
    const int lod = *reinterpret_cast<const int8_t*>(node + 0x4b);
    const auto count = *reinterpret_cast<const uint32_t*>(owner + 0x128);
    const auto begin = *reinterpret_cast<const uintptr_t*>(owner + 0x118);
    if (lod < 0 || lod > 2 || !begin || !count || count > 4096) { scope.valid = false; break; }
    const auto list = owner + 0x12c + lod * 12;
    const auto visible = *reinterpret_cast<const uint32_t*>(list + 8);
    const auto* entries = *reinterpret_cast<const uintptr_t* const*>(list);
    if (visible > count || visible > 2048 || (visible && !entries) || scope.instances.size() + visible > 4096) { scope.valid = false; break; }
    for (uint32_t i = 0; i < visible; ++i) {
      if (entries[i] < begin || (entries[i] - begin) % 44 || (entries[i] - begin) / 44 >= count) { scope.valid = false; break; }
      scope.instances.push_back({reinterpret_cast<const float*>(entries[i]), owner, *reinterpret_cast<const uintptr_t*>(owner + 0x158),
                                 count, uint32_t((entries[i] - begin) / 44), *reinterpret_cast<const uint8_t*>(node + 0x4c) != 0});
    }
  }
  swarm_scope = &scope;
  const auto result = swarm_function(renderer, view, frame, material, mesh, part, layout, nodes, options);
  swarm_scope = previous;
  scope.pending.clear();
  return result;
}

inline void __fastcall EulerHook(const float* angles, float* rotation) {
  euler_function(angles, rotation);
  auto* scope = swarm_scope;
  if (!scope || !scope->valid) return;
  if (scope->next >= scope->instances.size() || scope->instances[scope->next].data + 3 != angles) { scope->valid = false; return; }
  const auto& instance = scope->instances[scope->next++];
  const float scale = instance.data[6];
  // Observe the native Euler result instead of repeating its six trig calls.
  // c63310 multiplies T * R * uniform S and packs these three matrix rows.
  const WorldTransform world = {rotation[0] * scale, rotation[4] * scale, rotation[8] * scale, instance.data[0],
                                rotation[1] * scale, rotation[5] * scale, rotation[9] * scale, instance.data[1],
                                rotation[2] * scale, rotation[6] * scale, rotation[10] * scale, instance.data[2]};
  std::lock_guard lock(state->mutex);
  const auto pose = state->swarm_history.Record(state->frame.load(std::memory_order_relaxed), instance.owner, instance.group, instance.count, instance.slot, world);
  if (instance.instanced) scope->pending.push_back(pose);
}

inline void __fastcall DrawHook(uintptr_t mesh, uint32_t part, uintptr_t flags, uint32_t count, uintptr_t layout) {
  if (!swarm_scope) { draw_function(mesh, part, flags, count, layout); return; }
  const auto previous = swarm_batch;
  auto* scope = swarm_scope;
  if (scope) {
    if (scope->valid && count && scope->pending.size() == count)
      swarm_batch = scope->pending;
    else {
      scope->valid = false;
      swarm_batch = {};
    }
  }
  draw_function(mesh, part, flags, count, layout);
  swarm_batch = previous;
  if (scope) scope->pending.clear();
}

inline void __fastcall BatchHook(uintptr_t renderer, uintptr_t mesh, uint32_t part, const float* instances, uint32_t count, uint32_t stride, uintptr_t layout) {
  const auto previous = batch;
  if (state->enabled.load(std::memory_order_relaxed)) {
    batch = {instances, count, stride};
    if (stride == 64 || stride == 80) {
      const auto& packed = native_batches[stride == 80];
      if (packed.renderer == renderer && packed.mesh == mesh && packed.frame == state->frame.load(std::memory_order_relaxed)
          && packed.previous.size() == count && count <= 4096
          && instances == *reinterpret_cast<const float* const*>(renderer + (stride == 64 ? 0x4c : 0x58)))
        batch.previous = packed.previous;
    }
  }
  batch_function(renderer, mesh, part, instances, count, stride, layout);
  batch = previous;
}

inline void __fastcall DeformedHook(uintptr_t owner, uintptr_t renderer, uintptr_t transform) {
  const auto previous = deformed_owner;
  const auto previous_generation = deformed_generation;
  if (state->enabled.load(std::memory_order_relaxed)) {
    deformed_owner = owner;
    deformed_generation = 0;
    // CRenderApexBatcher sets this context before dispatching each native
    // proxy. PhysX render resources rotate; the type-9 proxy owns the actor.
    if (state->image && *reinterpret_cast<const uintptr_t*>(renderer) == state->image + 0x2151c00) {
      deformed_owner = 0;
      const auto object = *reinterpret_cast<const uintptr_t*>(renderer + 0x28);
      if (object && *reinterpret_cast<const uintptr_t*>(object) == state->image + 0x2153e78
          && *reinterpret_cast<const uint32_t*>(object + 0x10) == 9) {
        std::lock_guard lock(state->mutex);
        auto found = state->deformed_generations.find(object);
        if (found == state->deformed_generations.end() && state->deformed_generations.size() < 4096)
          found = state->deformed_generations.emplace(object, ++state->next_deformed_generation).first;
        if (found != state->deformed_generations.end()) {
          deformed_owner = object;
          deformed_generation = found->second;
        }
      }
    }
  }
  deformed_function(owner, renderer, transform);
  deformed_owner = previous;
  deformed_generation = previous_generation;
}

inline void __fastcall InstanceHook(uint32_t flags, uintptr_t context) {
  const auto previous = direct_object;
  const auto previous_mesh = direct_mesh;
  const bool enabled = state->enabled.load(std::memory_order_relaxed);
  const auto renderer = enabled ? *reinterpret_cast<const uintptr_t*>(context) : 0;
  const auto mesh = enabled ? *reinterpret_cast<const uintptr_t*>(context + 8) : 0;
  const auto frame = state->frame.load(std::memory_order_relaxed);
  std::array<uint32_t, 2> counts = {};
  ObjectPose pose;
  WorldTransform world = {};
  if (enabled) {
    direct_object = 0;
    direct_mesh = mesh;
    if (renderer) {
      counts = {*reinterpret_cast<const uint32_t*>(renderer + 0x54), *reinterpret_cast<const uint32_t*>(renderer + 0x60)};
      for (size_t i = 0; i < counts.size(); ++i) {
        if (counts[i] != 0) continue;
        auto& packed = native_batches[i];
        packed.renderer = renderer;
        packed.mesh = mesh;
        packed.frame = frame;
        packed.previous.clear();
      }
    }
    const auto object = *reinterpret_cast<const uintptr_t*>(context + 0x18);
    if (object) {
      const auto* matrix = reinterpret_cast<const float*>(object + 0x40);
      world = {matrix[0], matrix[4], matrix[8], matrix[12],
               matrix[1], matrix[5], matrix[9], matrix[13],
               matrix[2], matrix[6], matrix[10], matrix[14]};
      if (*reinterpret_cast<const uint32_t*>(object + 0x10) == 1) {
        // Some materials submit a single instance inside this function instead
        // of using BatchHook. Its scope identifies that draw without retaining
        // the native renderer's temporary packed instance memory.
        direct_object = object;
        std::lock_guard lock(state->mutex);
        state->history.Record(frame, *reinterpret_cast<const uintptr_t*>(object + 0x180), world);
        // Type 1 includes non-skinned meshes with a null allocation. Other
        // render-object types have different lifetimes and are not observed.
        pose = state->rigid_history.Record(frame, object, mesh, world);
      }
    }
  }
  instance_function(flags, context);
  if (enabled && renderer) {
    for (size_t i = 0; i < counts.size(); ++i) {
      const auto count = *reinterpret_cast<const uint32_t*>(renderer + (i == 0 ? 0x54 : 0x60));
      auto& packed = native_batches[i];
      if (count != counts[i] + 1 || count > 4096 || packed.previous.size() != counts[i]
          || packed.renderer != renderer || packed.mesh != mesh || packed.frame != frame) continue;
      const auto* instances = *reinterpret_cast<const float* const*>(renderer + (i == 0 ? 0x4c : 0x58));
      // Reject a native permutation that substituted a different transform.
      // The remaining instances keep their independent, exact identities.
      packed.previous.push_back(direct_object && std::equal(world.begin(), world.end(), instances + counts[i] * (i == 0 ? 16 : 20)) ? pose : ObjectPose{});
    }
  }
  direct_object = previous;
  direct_mesh = previous_mesh;
}
inline void __fastcall FreeHook(uintptr_t renderer, uintptr_t allocation) {
  if (state->enabled.load(std::memory_order_relaxed)) {
    std::lock_guard lock(state->mutex);
    state->history.Erase(allocation);
  }
  free_function(renderer, allocation);
}

inline void __fastcall ObjectFreeHook(uintptr_t object) {
  if (state->enabled.load(std::memory_order_relaxed)) {
    std::lock_guard lock(state->mutex);
    state->rigid_history.Erase(object);
    state->deformed_generations.erase(object);
    state->swarm_history.Erase(object);
  }
  object_free_function(object);
}

inline bool Install() {
  if (state->installed) return true;
  Camera verified;
  if (!verified.Initialize()) return false;
  const auto image = reinterpret_cast<uintptr_t>(GetModuleHandleW(nullptr));
  if (!upscale_engine::Verify(image)) return false;
  constexpr uint8_t instance_prefix[] = {72, 137, 92, 36, 32, 85, 86, 87, 72, 141, 108, 36, 185, 72, 129, 236, 160, 0, 0, 0, 72, 139, 250, 15};
  constexpr uint8_t free_prefix[] = {72, 137, 92, 36, 8, 72, 137, 116, 36, 16, 87, 72, 131, 236, 32, 72, 139, 241, 72, 131, 193, 48, 72, 139};
  constexpr uint8_t deformed_prefix[] = {72, 137, 92, 36, 24, 72, 137, 124, 36, 32, 85, 65, 84, 65, 86, 72, 141, 108, 36, 192, 72, 129, 236, 64};
  constexpr uint8_t object_free_prefix[] = {72, 137, 92, 36, 8, 87, 72, 131, 236, 80, 72, 141, 5, 247, 160, 70, 1, 51, 255, 72, 139, 217, 72, 137};
  constexpr uint8_t batch_prefix[] = {72, 137, 92, 36, 24, 65, 84, 65, 86, 65, 87, 72, 131, 236, 48, 139, 92, 36, 112, 77, 139, 241, 69, 139};
  constexpr uint8_t swarm_prefix[] = {72, 139, 196, 72, 137, 88, 24, 72, 137, 80, 16, 72, 137, 72, 8, 85, 86, 87, 65, 84, 65, 85, 65, 86};
  constexpr uint8_t euler_prefix[] = {72, 139, 196, 72, 137, 88, 8, 87, 72, 129, 236, 128, 0, 0, 0, 15, 41, 112, 232, 243, 15, 16, 49, 15};
  constexpr uint8_t draw_prefix[] = {72, 131, 236, 72, 131, 121, 100, 0, 69, 139, 209, 116, 67, 131, 121, 96, 0, 116, 61, 72, 99, 194, 68, 137};
  if (std::memcmp(reinterpret_cast<void*>(image + 0xc5afa0), instance_prefix, sizeof(instance_prefix))
      || std::memcmp(reinterpret_cast<void*>(image + 0xc669c0), free_prefix, sizeof(free_prefix))
      || std::memcmp(reinterpret_cast<void*>(image + 0x116cdc0), deformed_prefix, sizeof(deformed_prefix))
      || std::memcmp(reinterpret_cast<void*>(image + 0xcefca0), object_free_prefix, sizeof(object_free_prefix))
      || std::memcmp(reinterpret_cast<void*>(image + 0xc5a4f0), batch_prefix, sizeof(batch_prefix))
      || std::memcmp(reinterpret_cast<void*>(image + 0xc63310), swarm_prefix, sizeof(swarm_prefix))
      || std::memcmp(reinterpret_cast<void*>(image + 0x1fca80), euler_prefix, sizeof(euler_prefix))
      || std::memcmp(reinterpret_cast<void*>(image + 0xbddc80), draw_prefix, sizeof(draw_prefix))) return false;
  // Common render-proxy base destructor, reached by mesh, Apex and swarm
  // destructors. Invalidate identity before native storage can be reused.
  object_free_function = reinterpret_cast<ObjectFreeFunction>(image + 0xcefca0);
  instance_function = reinterpret_cast<InstanceFunction>(image + 0xc5afa0);
  free_function = reinterpret_cast<FreeFunction>(image + 0xc669c0);
  deformed_function = reinterpret_cast<DeformedFunction>(image + 0x116cdc0);
  batch_function = reinterpret_cast<BatchFunction>(image + 0xc5a4f0);
  swarm_function = reinterpret_cast<SwarmFunction>(image + 0xc63310);
  euler_function = reinterpret_cast<EulerFunction>(image + 0x1fca80);
  draw_function = reinterpret_cast<DrawFunction>(image + 0xbddc80);
  state->registry_address = image + 0x2bcbb48;
  state->image = image;
  HMODULE pinned = nullptr;
  if (!GetModuleHandleExW(GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS | GET_MODULE_HANDLE_EX_FLAG_PIN,
                          reinterpret_cast<LPCWSTR>(&Install), &pinned)) return false;
  const HANDLE snapshot = CreateToolhelp32Snapshot(TH32CS_SNAPTHREAD, 0);
  if (snapshot == INVALID_HANDLE_VALUE) return false;
  std::vector<HANDLE> threads;
  THREADENTRY32 entry{sizeof(entry)};
  bool valid = Thread32First(snapshot, &entry) != FALSE;
  if (valid) do {
      if (entry.th32OwnerProcessID != GetCurrentProcessId() || entry.th32ThreadID == GetCurrentThreadId()) continue;
      const HANDLE thread = OpenThread(THREAD_SUSPEND_RESUME | THREAD_GET_CONTEXT | THREAD_SET_CONTEXT | THREAD_QUERY_INFORMATION, FALSE, entry.th32ThreadID);
      if (!thread) {
        valid = false;
        break;
      }
      threads.push_back(thread);
    } while (Thread32Next(snapshot, &entry));
  CloseHandle(snapshot);
  if (valid && DetourTransactionBegin() == NO_ERROR) {
    valid = DetourUpdateThread(GetCurrentThread()) == NO_ERROR;
    for (HANDLE thread : threads)
      if (valid) valid = DetourUpdateThread(thread) == NO_ERROR;
    if (valid) valid = DetourAttach(reinterpret_cast<void**>(&instance_function), reinterpret_cast<void*>(&InstanceHook)) == NO_ERROR
                       && DetourAttach(reinterpret_cast<void**>(&free_function), reinterpret_cast<void*>(&FreeHook)) == NO_ERROR
                       && DetourAttach(reinterpret_cast<void**>(&deformed_function), reinterpret_cast<void*>(&DeformedHook)) == NO_ERROR
                       && DetourAttach(reinterpret_cast<void**>(&object_free_function), reinterpret_cast<void*>(&ObjectFreeHook)) == NO_ERROR
                       && DetourAttach(reinterpret_cast<void**>(&batch_function), reinterpret_cast<void*>(&BatchHook)) == NO_ERROR
                       && DetourAttach(reinterpret_cast<void**>(&swarm_function), reinterpret_cast<void*>(&SwarmHook)) == NO_ERROR
                       && DetourAttach(reinterpret_cast<void**>(&euler_function), reinterpret_cast<void*>(&EulerHook)) == NO_ERROR
                       && DetourAttach(reinterpret_cast<void**>(&draw_function), reinterpret_cast<void*>(&DrawHook)) == NO_ERROR
                       && DetourAttach(reinterpret_cast<void**>(&upscale_engine::render_function), reinterpret_cast<void*>(&upscale_engine::RenderHook)) == NO_ERROR
                       && DetourAttach(reinterpret_cast<void**>(&upscale_engine::post_function), reinterpret_cast<void*>(&upscale_engine::PostHook)) == NO_ERROR
                       && DetourAttach(reinterpret_cast<void**>(&upscale_engine::jitter_function), reinterpret_cast<void*>(&upscale_engine::JitterHook)) == NO_ERROR;
    if (valid)
      state->installed = DetourTransactionCommit() == NO_ERROR;
    else
      DetourTransactionAbort();
  }
  for (HANDLE thread : threads) CloseHandle(thread);
  return state->installed;
}

inline bool Allocations(uint32_t capacity, std::vector<BoneAllocation>* output) {
  output->clear();
  if (!state->installed) return false;
  const auto registry = *reinterpret_cast<const uintptr_t*>(state->registry_address);
  if (!registry) return false;
  const auto renderer = *reinterpret_cast<const uintptr_t*>(registry + 0xb8);
  if (!renderer) return false;
  output->reserve(4096);
  auto* critical_section = reinterpret_cast<CRITICAL_SECTION*>(renderer + 0x30);
  EnterCriticalSection(critical_section);
  const auto count = *reinterpret_cast<const uint32_t*>(renderer + 0x60);
  const auto* allocations = *reinterpret_cast<const uintptr_t* const*>(renderer + 0x58);
  bool valid = count <= 4096 && (!count || allocations);
  if (valid)
    for (uint32_t i = 0; i < count; ++i) {
      const auto allocation = allocations[i];
      if (!allocation) continue;
      const float base = *reinterpret_cast<const float*>(allocation + 0x20);
      const auto bones = *reinterpret_cast<const uint32_t*>(allocation + 0x1c);
      if (!std::isfinite(base) || base < 1 || base >= capacity || !bones || bones > capacity - uint32_t(base)
          || base != float(uint32_t(base))) {
        // Inactive allocations can stay registered while their upload is not
        // available in this palette. Reject that allocation alone; unrelated
        // meshes must retain their history for this frame.
        continue;
      }
      output->push_back({allocation, *reinterpret_cast<const uintptr_t*>(allocation + 0x38), uint32_t(base), bones});
    }
  LeaveCriticalSection(critical_section);
  if (!valid) output->clear();
  return valid;
}

inline void Disable() {
  state->enabled.store(false, std::memory_order_relaxed);
  std::lock_guard lock(state->mutex);
  state->history.Clear();
  state->rigid_history.Clear();
  state->deformed_generations.clear();
  state->swarm_history.Clear();
}
}  // namespace witcher3classic::temporal::object_engine
