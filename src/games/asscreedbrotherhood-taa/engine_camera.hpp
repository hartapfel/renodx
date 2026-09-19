/*
 * Copyright (C) 2026 Hartapfel
 * SPDX-License-Identifier: MIT
 */
#pragma once

#include <windows.h>
#include <tlhelp32.h>
#include <detours.h>
#include <intrin.h>
#include <array>
#include <atomic>
#include <cstring>
#include <unordered_map>
#include <vector>

#include "./taa_camera.hpp"
#include "./taa_jitter.hpp"

namespace acbrotherhood::engine_camera {

using taa::Matrix;
using SetProjection = void(__thiscall*)(void*, const Matrix*);
using BuildCommands = void(__thiscall*)(void*, void*);
using ExecuteCommands = void(__thiscall*)(void*, void*, void*);
using CopyContext = void*(__thiscall*)(void*, const void*);
using PrepareView = unsigned(__thiscall*)(void*, void*, void*, void*);
using WriteConstants = void(__thiscall*)(void*, unsigned, const float*, unsigned);
using UploadConstants = void*(__thiscall*)(void*, void*, void*);
inline SetProjection set_projection = nullptr;
inline BuildCommands build_commands = nullptr;
inline ExecuteCommands execute_commands = nullptr;
inline CopyContext copy_context = nullptr;
inline PrepareView prepare_view = nullptr;
inline WriteConstants write_constants = nullptr;
inline UploadConstants upload_constants = nullptr;
inline uintptr_t image_base = 0;
inline bool installed = false, attempted = false;

struct Configuration {
  uintptr_t renderer = 0, camera = 0;
  unsigned width = 0, height = 0, samples = 0, epoch = 0;
  bool enabled = false;
};
struct Frame {
  Configuration configuration;
  uint64_t id = 0;
  unsigned phase = 0;
  std::array<float, 2> jitter = {};
  bool owned = false;
};

struct Projection {
  Matrix projection = {}, view = {}, camera = {};
  uintptr_t context = 0, source = 0, caller = 0, camera_object = 0;
  std::array<float, 4> viewport = {};
  uint64_t serial = 0;
  Frame frame;
  bool main_view = false, modified = false;
};
struct Stamp {
  uintptr_t payload = 0;
  Projection projection;
};
struct Batch {
  Projection current;
  std::vector<Stamp> stamps;
  uintptr_t renderer = 0, job = 0, begin = 0, end = 0;
  unsigned slot = 0, thread = 0;
  uint64_t serial = 0;
};
inline SRWLOCK batch_lock = SRWLOCK_INIT;
inline std::unordered_map<void*, Batch> batches;
inline std::array<Projection, 128> recent_projections;
inline std::unordered_map<const void*, Projection> contexts;
inline std::unordered_map<const void*, Frame> frames;
inline Configuration configuration;
inline uint64_t next_frame = 0;
inline unsigned next_phase = 0;
inline std::atomic<uint64_t> built = 0, executed = 0, setters = 0;
inline std::atomic<uint64_t> modified = 0, tagged = 0, consumed = 0;
inline thread_local Batch* producing = nullptr;
inline thread_local const Batch* consuming = nullptr;
inline thread_local Projection render_projection, direct_projection;
inline thread_local size_t stamp_index = 0;

inline const Projection* Current() {
  const auto& projection = consuming ? render_projection : direct_projection;
  return projection.frame.id ? &projection : nullptr;
}

inline void Configure(const Configuration& requested) {
  AcquireSRWLockExclusive(&batch_lock);
  const bool changed = configuration.renderer != requested.renderer || configuration.camera != requested.camera
                       || configuration.width != requested.width || configuration.height != requested.height
                       || configuration.samples != requested.samples || configuration.enabled != requested.enabled;
  const unsigned epoch = configuration.epoch + unsigned(changed);
  configuration = requested;
  configuration.epoch = epoch;
  if (changed) next_phase = 0;
  ReleaseSRWLockExclusive(&batch_lock);
}

inline unsigned __fastcall PrepareHook(void* renderer, void*, void* scene, void* view, void* output) {
  void* context = nullptr;
  std::memcpy(&context, static_cast<unsigned char*>(renderer) + 0xaa8, sizeof(context));
  AcquireSRWLockExclusive(&batch_lock);
  Frame frame;
  frame.configuration = configuration;
  frame.id = ++next_frame;
  frame.owned = configuration.renderer == reinterpret_cast<uintptr_t>(renderer) && configuration.camera != 0;
  if (frame.owned && configuration.enabled) {
    frame.phase = next_phase++;
    frame.jitter = taa::Jitter(frame.phase);
    if (configuration.samples) for (float& value : frame.jitter) value *= 0.5f;
  }
  if (frames.size() >= 64) frames.clear();
  frames.insert_or_assign(context, frame);
  ReleaseSRWLockExclusive(&batch_lock);
  return prepare_view(renderer, scene, view, output);
}

inline void __fastcall ProjectionHook(void* context, void*, const Matrix* projection) {
  const uintptr_t caller = reinterpret_cast<uintptr_t>(_ReturnAddress()) - image_base;
  Projection record;
  record.serial = ++setters;
  record.context = reinterpret_cast<uintptr_t>(context);
  record.source = reinterpret_cast<uintptr_t>(projection);
  record.caller = caller;
  record.projection = *projection;
  AcquireSRWLockShared(&batch_lock);
  if (auto found = frames.find(context); found != frames.end()) record.frame = found->second;
  else if (auto found = contexts.find(context); found != contexts.end()) record.frame = found->second.frame;
  ReleaseSRWLockShared(&batch_lock);
  std::memcpy(&record.view, static_cast<unsigned char*>(context) + 0x270, sizeof(Matrix));
  // The engine stores row-vector matrices, transposed before shader upload.
  DirectX::XMStoreFloat4x4(&record.camera, DirectX::XMMatrixTranspose(DirectX::XMMatrixMultiply(
      DirectX::XMLoadFloat4x4(&record.view), DirectX::XMLoadFloat4x4(projection))));
  std::memcpy(&record.camera_object, static_cast<unsigned char*>(context) + 0x10, sizeof(void*));
  // Only this audited caller passes camera+0xe0; other callers can use stack matrices.
  if ((caller == 0x76e7a2 || caller == 0x76e8a5 || caller == 0x76f92e)
      && record.source == record.camera_object + 0xe0)
    std::memcpy(record.viewport.data(), reinterpret_cast<const void*>(record.camera_object + 0x84), sizeof(record.viewport));
  const auto& config = record.frame.configuration;
  record.main_view = record.frame.owned && record.camera_object == config.camera
                     && record.viewport == std::array<float, 4>{0.f, 0.f, float(config.width), float(config.height)};
  alignas(16) Matrix jittered = *projection;
  record.modified = record.main_view && config.enabled && config.width && config.height;
  if (record.modified) {
    for (unsigned row = 0; row < 4; ++row) {
      jittered.m[row][0] += 2.f * record.frame.jitter[0] / config.width * projection->m[row][3];
      jittered.m[row][1] -= 2.f * record.frame.jitter[1] / config.height * projection->m[row][3];
    }
    ++modified;
  }
  set_projection(context, record.modified ? &jittered : projection);
  if (producing) producing->current = record;
  else direct_projection = record;
  AcquireSRWLockExclusive(&batch_lock);
  recent_projections[record.serial % recent_projections.size()] = record;
  if (contexts.size() >= 128) contexts.clear();
  contexts.insert_or_assign(context, record);
  ReleaseSRWLockExclusive(&batch_lock);
}

inline void* __fastcall CopyHook(void* context, void*, const void* source) {
  void* result = copy_context(context, source);
  Projection record;
  AcquireSRWLockExclusive(&batch_lock);
  if (auto found = contexts.find(source); found != contexts.end()) record = found->second;
  record.context = reinterpret_cast<uintptr_t>(context);
  std::memcpy(&record.camera, static_cast<unsigned char*>(context) + 0x330, sizeof(Matrix));
  DirectX::XMStoreFloat4x4(&record.camera, DirectX::XMMatrixTranspose(DirectX::XMLoadFloat4x4(&record.camera)));
  if (record.modified) {
    for (unsigned column = 0; column < 4; ++column) {
      record.camera.m[0][column] -= 2.f * record.frame.jitter[0] / record.frame.configuration.width * record.camera.m[3][column];
      record.camera.m[1][column] += 2.f * record.frame.jitter[1] / record.frame.configuration.height * record.camera.m[3][column];
    }
  }
  if (contexts.size() >= 128) contexts.clear();
  contexts.insert_or_assign(context, record);
  ReleaseSRWLockExclusive(&batch_lock);
  if (producing) producing->current = record;
  else direct_projection = record;
  return result;
}

inline void __fastcall BuildHook(void* renderer, void*, void* job) {
  Batch batch;
  batch.renderer = reinterpret_cast<uintptr_t>(renderer);
  batch.job = reinterpret_cast<uintptr_t>(job);
  batch.thread = GetCurrentThreadId();
  batch.serial = ++built;
  std::memcpy(&batch.slot, static_cast<unsigned char*>(renderer) + 0xfe8, sizeof(batch.slot));
  auto* previous = producing;
  producing = &batch;
  build_commands(renderer, job);
  producing = previous;
  // The engine writes this exact descriptor into job+0x18 at job completion.
  void* descriptor = static_cast<unsigned char*>(job) + 0x18;
  std::memcpy(&batch.begin, static_cast<unsigned char*>(descriptor) + 4, sizeof(void*));
  std::memcpy(&batch.end, static_cast<unsigned char*>(descriptor) + 8, sizeof(void*));
  AcquireSRWLockExclusive(&batch_lock);
  if (batches.size() >= 512) batches.clear();
  batches.insert_or_assign(descriptor, std::move(batch));
  ReleaseSRWLockExclusive(&batch_lock);
}

inline void __fastcall ExecuteHook(void* context, void*, void* device, void* descriptor) {
  Batch batch;
  bool found = false;
  uintptr_t begin = 0, end = 0;
  std::memcpy(&begin, static_cast<unsigned char*>(descriptor) + 4, sizeof(void*));
  std::memcpy(&end, static_cast<unsigned char*>(descriptor) + 8, sizeof(void*));
  AcquireSRWLockExclusive(&batch_lock);
  if (auto entry = batches.find(descriptor); entry != batches.end()) {
    if (entry->second.begin == begin && entry->second.end == end) {
      batch = std::move(entry->second);
      found = true;
    }
    batches.erase(entry);
  }
  ReleaseSRWLockExclusive(&batch_lock);
  if (found) ++executed;
  auto* previous = consuming;
  const auto previous_projection = render_projection;
  const auto previous_stamp = stamp_index;
  consuming = found ? &batch : nullptr;
  render_projection = {};
  stamp_index = 0;
  execute_commands(context, device, descriptor);
  consuming = previous;
  render_projection = previous_projection;
  stamp_index = previous_stamp;
}

inline void __fastcall WriteHook(void* stream, void*, unsigned start, const float* values, unsigned count) {
  write_constants(stream, start, values, count);
  if (!producing || start >= 4 || !count || count > 256) return;
  const auto& current = producing->current;
  if (!producing->stamps.empty() && producing->stamps.back().projection.serial == current.serial) return;
  uintptr_t end = 0;
  std::memcpy(&end, static_cast<unsigned char*>(stream) + 8, sizeof(void*));
  producing->stamps.push_back({end - count * 16 - 4, current});
  ++tagged;
}

inline void* __fastcall UploadHook(void* context, void*, void* device, void* payload) {
  if (consuming && stamp_index < consuming->stamps.size()
      && consuming->stamps[stamp_index].payload == reinterpret_cast<uintptr_t>(payload)) {
    render_projection = consuming->stamps[stamp_index++].projection;
    ++consumed;
  }
  return upload_constants(context, device, payload);
}

inline Matrix Unjitter(const Matrix& clip) {
  Matrix result = clip;
  if (const auto* current = Current(); current && current->modified) {
    for (unsigned column = 0; column < 4; ++column) {
      result.m[0][column] -= 2.f * current->frame.jitter[0] / current->frame.configuration.width * clip.m[3][column];
      result.m[1][column] += 2.f * current->frame.jitter[1] / current->frame.configuration.height * clip.m[3][column];
    }
  }
  return result;
}

inline bool FindCamera(const Matrix& camera, Projection* result) {
  if (const auto* current = Current(); current && taa::SameCamera(camera, current->camera)) {
    *result = *current;
    return true;
  }
  bool found = false;
  AcquireSRWLockShared(&batch_lock);
  for (const auto& projection : recent_projections) {
    if (projection.serial && taa::SameCamera(camera, projection.camera)
        && (!found || projection.serial > result->serial)) {
      *result = projection;
      found = true;
    }
  }
  ReleaseSRWLockShared(&batch_lock);
  return found;
}

inline bool Install() {
  if (attempted) return installed;
  attempted = true;
#if defined(_M_IX86)
  image_base = reinterpret_cast<uintptr_t>(GetModuleHandleW(nullptr));
  const auto* dos = reinterpret_cast<const IMAGE_DOS_HEADER*>(image_base);
  if (!dos || dos->e_magic != IMAGE_DOS_SIGNATURE || dos->e_lfanew < 0 || dos->e_lfanew > 0x1000) return false;
  const auto* pe = reinterpret_cast<const IMAGE_NT_HEADERS*>(image_base + dos->e_lfanew);
  if (pe->Signature != IMAGE_NT_SIGNATURE || pe->FileHeader.Machine != IMAGE_FILE_MACHINE_I386
      || pe->FileHeader.TimeDateStamp != 0x635a87c1 || pe->OptionalHeader.SizeOfImage != 0x2e02000) return false;
  // Version and relocated-code contracts from the local Ghidra audit. These
  // checks intentionally reject unknown executables instead of scanning guesses.
  constexpr unsigned char projection_prefix[] = {0x53,0x8b,0xdc,0x83,0xec,0x08,0x83,0xe4,0xf0,0x83,0xc4,0x04};
  constexpr unsigned char build_prefix[] = {0x55,0x8b,0xec,0x83,0xec,0x10};
  constexpr unsigned char execute_prefix[] = {0x55,0x8b,0xec,0x8b,0x55,0x0c,0x8b,0x42,0x04,0x53,0x56,0x8b,0x72,0x08};
  constexpr unsigned char prepare_prefix[] = {0x55,0x8b,0xec,0x56,0x8b,0xf1,0x83,0x7e,0x7c,0x00};
  constexpr unsigned char write_prefix[] = {0x55,0x8b,0xec,0x83,0xec,0x08,0x56,0x8b,0xf1,0x8b,0x46,0x08};
  constexpr unsigned char upload_prefix[] = {0x55,0x8b,0xec,0x8b,0x45,0x08,0x8b,0x40,0x0c,0x8b,0x08};
  if (std::memcmp(reinterpret_cast<void*>(image_base + 0x715a50), projection_prefix, sizeof(projection_prefix))
      || std::memcmp(reinterpret_cast<void*>(image_base + 0x749250), build_prefix, sizeof(build_prefix))
      || std::memcmp(reinterpret_cast<void*>(image_base + 0x70aed0), execute_prefix, sizeof(execute_prefix))
      || std::memcmp(reinterpret_cast<void*>(image_base + 0x74fca0), projection_prefix, sizeof(projection_prefix))
      || std::memcmp(reinterpret_cast<void*>(image_base + 0x744860), prepare_prefix, sizeof(prepare_prefix))
      || std::memcmp(reinterpret_cast<void*>(image_base + 0x70b390), write_prefix, sizeof(write_prefix))
      || std::memcmp(reinterpret_cast<void*>(image_base + 0x70c150), upload_prefix, sizeof(upload_prefix))) return false;
  set_projection = reinterpret_cast<SetProjection>(image_base + 0x715a50);
  build_commands = reinterpret_cast<BuildCommands>(image_base + 0x749250);
  execute_commands = reinterpret_cast<ExecuteCommands>(image_base + 0x70aed0);
  copy_context = reinterpret_cast<CopyContext>(image_base + 0x74fca0);
  prepare_view = reinterpret_cast<PrepareView>(image_base + 0x744860);
  write_constants = reinterpret_cast<WriteConstants>(image_base + 0x70b390);
  upload_constants = reinterpret_cast<UploadConstants>(image_base + 0x70c150);
  // Keep callbacks alive until process exit, including queued worker calls.
  HMODULE pinned = nullptr;
  if (!GetModuleHandleExW(GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS | GET_MODULE_HANDLE_EX_FLAG_PIN,
                         reinterpret_cast<LPCWSTR>(&Install), &pinned)) return false;
  HANDLE snapshot = CreateToolhelp32Snapshot(TH32CS_SNAPTHREAD, 0);
  if (snapshot == INVALID_HANDLE_VALUE) return false;
  std::vector<HANDLE> threads;
  THREADENTRY32 entry{sizeof(entry)};
  bool valid = Thread32First(snapshot, &entry) != FALSE;
  if (valid) do {
    if (entry.th32OwnerProcessID != GetCurrentProcessId() || entry.th32ThreadID == GetCurrentThreadId()) continue;
    HANDLE thread = OpenThread(THREAD_SUSPEND_RESUME | THREAD_GET_CONTEXT | THREAD_SET_CONTEXT | THREAD_QUERY_INFORMATION,
                               FALSE, entry.th32ThreadID);
    if (!thread) { valid = false; break; }
    threads.push_back(thread);
  } while (Thread32Next(snapshot, &entry));
  CloseHandle(snapshot);
  if (valid && DetourTransactionBegin() == NO_ERROR) {
    valid = DetourUpdateThread(GetCurrentThread()) == NO_ERROR;
    for (HANDLE thread : threads) if (valid) valid = DetourUpdateThread(thread) == NO_ERROR;
    if (valid) valid = DetourAttach(reinterpret_cast<void**>(&set_projection), reinterpret_cast<void*>(&ProjectionHook)) == NO_ERROR
                       && DetourAttach(reinterpret_cast<void**>(&build_commands), reinterpret_cast<void*>(&BuildHook)) == NO_ERROR
                       && DetourAttach(reinterpret_cast<void**>(&execute_commands), reinterpret_cast<void*>(&ExecuteHook)) == NO_ERROR
                       && DetourAttach(reinterpret_cast<void**>(&copy_context), reinterpret_cast<void*>(&CopyHook)) == NO_ERROR
                       && DetourAttach(reinterpret_cast<void**>(&prepare_view), reinterpret_cast<void*>(&PrepareHook)) == NO_ERROR
                       && DetourAttach(reinterpret_cast<void**>(&write_constants), reinterpret_cast<void*>(&WriteHook)) == NO_ERROR
                       && DetourAttach(reinterpret_cast<void**>(&upload_constants), reinterpret_cast<void*>(&UploadHook)) == NO_ERROR;
    if (valid) installed = DetourTransactionCommit() == NO_ERROR;
    else DetourTransactionAbort();
  }
  for (HANDLE thread : threads) CloseHandle(thread);
#endif
  return installed;
}

}  // namespace acbrotherhood::engine_camera
