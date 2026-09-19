/*
 * Copyright (C) 2026 Hartapfel
 * SPDX-License-Identifier: MIT
 */
#define NOMINMAX
#include <cassert>
#include <cstdio>
#include <thread>
#include "../engine_camera.hpp"
using namespace acbrotherhood::engine_camera;
alignas(16) unsigned char main_context[0x3a0] = {}, worker_context[0x3a0] = {}, renderer[0x1100] = {}, camera_object[0x200] = {};
struct Job {
  unsigned char descriptor[0x4c] = {};
  alignas(16) unsigned char packet[128] = {};
  Matrix expected;
  Frame frame;
};
using SetterStub = void(__cdecl*)(void*, const Matrix*);
SetterStub stub;
thread_local Job* current_job;
Matrix original_projection, original_view;
unsigned observations = 0;
void __fastcall NativeProjection(void* ctx, void*, const Matrix* p) {
  assert((reinterpret_cast<uintptr_t>(p) & 15) == 0);
  std::memcpy(static_cast<unsigned char*>(ctx) + 0x230, p, sizeof(Matrix));
  Matrix v;
  std::memcpy(&v, static_cast<unsigned char*>(ctx) + 0x270, sizeof(Matrix));
  DirectX::XMStoreFloat4x4(reinterpret_cast<Matrix*>(static_cast<unsigned char*>(ctx) + 0x330),
                           DirectX::XMMatrixMultiply(DirectX::XMLoadFloat4x4(&v), DirectX::XMLoadFloat4x4(p)));
}
void* __fastcall NativeCopy(void* ctx, void*, const void* src) {
  std::memcpy(ctx, src, 0x3a0);
  return ctx;
}
unsigned __fastcall NativePrepare(void*, void*, void*, void*, void*) {
  stub(main_context, reinterpret_cast<Matrix*>(camera_object + 0xe0));
  return 1;
}
void __fastcall NativeWrite(void* stream, void*, unsigned start, const float* values, unsigned count) {
  uintptr_t cursor;
  std::memcpy(&cursor, static_cast<unsigned char*>(stream) + 8, sizeof(cursor));
  const uint32_t header = (count << 16) | start;
  std::memcpy(reinterpret_cast<void*>(cursor), &header, 4);
  std::memcpy(reinterpret_cast<void*>(cursor + 4), values, count * 16);
  cursor += 4 + count * 16;
  std::memcpy(static_cast<unsigned char*>(stream) + 8, &cursor, sizeof(cursor));
}
void* __fastcall NativeUpload(void*, void*, void*, void* payload) {
  const auto* p = Current();
  assert(p && p->main_view);
  assert(p->frame.id == current_job->frame.id);
  assert(p->frame.jitter == current_job->frame.jitter);
  uint32_t header;
  std::memcpy(&header, payload, sizeof(header));
  if ((header >> 16) == 1) {
    assert((header & 0xffff) == 1 && stamp_index == 1);
    return static_cast<unsigned char*>(payload) + 20;
  }
  Matrix gpu;
  std::memcpy(&gpu, static_cast<unsigned char*>(payload) + 4, sizeof(gpu));
  Matrix recovered = Unjitter(gpu);
  for (unsigned r = 0; r < 4; ++r)
    for (unsigned c = 0; c < 4; ++c) assert(std::abs(recovered.m[r][c] - current_job->expected.m[r][c]) < .0001f);
  ++observations;
  return static_cast<unsigned char*>(payload) + 68;
}
void __fastcall NativeBuild(void*, void*, void* data) {
  auto* job = reinterpret_cast<Job*>(data);
  CopyHook(worker_context, nullptr, main_context);
  assert(producing->current.main_view && producing->current.modified);
  job->frame = producing->current.frame;
  job->expected = producing->current.camera;
  unsigned char stream[16] = {};
  uintptr_t cursor = reinterpret_cast<uintptr_t>(job->packet);
  std::memcpy(stream + 8, &cursor, sizeof(cursor));
  Matrix clip;
  std::memcpy(&clip, worker_context + 0x330, sizeof(clip));
  DirectX::XMStoreFloat4x4(&clip, DirectX::XMMatrixTranspose(DirectX::XMLoadFloat4x4(&clip)));
  WriteHook(stream, nullptr, 0, &clip.m[0][0], 4);
  // A later partial update must retain the sample, without another metadata allocation.
  WriteHook(stream, nullptr, 1, &clip.m[1][0], 1);
  assert(producing->stamps.size() == 1);
  uintptr_t end;
  std::memcpy(&end, stream + 8, sizeof(end));
  std::memcpy(job->descriptor + 0x1c, &cursor, sizeof(cursor));
  std::memcpy(job->descriptor + 0x20, &end, sizeof(end));
}
void __fastcall NativeExecute(void*, void*, void*, void*) {
  assert(consuming && consuming->stamps.size() == 1);
  UploadHook(nullptr, nullptr, nullptr, current_job->packet);
  // The packet writer may emit only c1 after c0-c3. The upload callback must
  // still observe the same camera without consuming another stamp.
  UploadHook(nullptr, nullptr, nullptr, current_job->packet + 68);
  assert(Current()->frame.id == current_job->frame.id && stamp_index == 1);
}
int main() {
  assert(!Install());
  set_projection = reinterpret_cast<SetProjection>(&NativeProjection);
  copy_context = reinterpret_cast<acbrotherhood::engine_camera::CopyContext>(&NativeCopy);
  prepare_view = reinterpret_cast<PrepareView>(&NativePrepare);
  build_commands = reinterpret_cast<BuildCommands>(&NativeBuild);
  execute_commands = reinterpret_cast<ExecuteCommands>(&NativeExecute);
  write_constants = reinterpret_cast<WriteConstants>(&NativeWrite);
  upload_constants = reinterpret_cast<UploadConstants>(&NativeUpload);
  // Exercise the real x86 thiscall/fastcall stack contract with the audited call-site identity.
  unsigned char code[] = {0x8b, 0x4c, 0x24, 0x04, 0xff, 0x74, 0x24, 0x08, 0x33, 0xd2, 0xb8, 0, 0, 0, 0, 0xff, 0xd0, 0xc3};
  auto* executable = static_cast<unsigned char*>(VirtualAlloc(nullptr, 4096, MEM_RESERVE | MEM_COMMIT, PAGE_READWRITE));
  assert(executable);
  uintptr_t target = reinterpret_cast<uintptr_t>(&ProjectionHook);
  std::memcpy(code + 11, &target, 4);
  std::memcpy(executable, code, sizeof(code));
  DWORD old;
  assert(VirtualProtect(executable, 4096, PAGE_EXECUTE_READ, &old));
  FlushInstructionCache(GetCurrentProcess(), executable, sizeof(code));
  stub = reinterpret_cast<SetterStub>(executable);
  image_base = reinterpret_cast<uintptr_t>(executable) + 17 - 0x76e7a2;
  void* context_pointer = main_context;
  std::memcpy(renderer + 0xaa8, &context_pointer, sizeof(context_pointer));
  void* camera_pointer = camera_object;
  std::memcpy(main_context + 0x10, &camera_pointer, sizeof(camera_pointer));
  const std::array<float, 4> viewport = {0, 0, 3840, 2160};
  std::memcpy(camera_object + 0x84, viewport.data(), 16);
  DirectX::XMStoreFloat4x4(&original_projection, DirectX::XMMatrixPerspectiveFovLH(1.f, 16.f / 9, .1f, 2000.f));
  DirectX::XMStoreFloat4x4(&original_view, DirectX::XMMatrixLookAtLH({10, 4, -30, 1}, {5, 3, 0, 1}, {0, 1, 0, 0}));
  std::memcpy(camera_object + 0xe0, &original_projection, sizeof(Matrix));
  std::memcpy(main_context + 0x270, &original_view, sizeof(Matrix));
  for (unsigned samples : {0u, 8u}) {
    Configure({reinterpret_cast<uintptr_t>(renderer), reinterpret_cast<uintptr_t>(camera_object), 3840, 2160, samples, 0, true});
    for (unsigned n = 0; n < 8; ++n) {
      Job a, b;
      assert(PrepareHook(renderer, nullptr, nullptr, nullptr, nullptr));
      const Frame frame = direct_projection.frame;
      Matrix changed;
      std::memcpy(&changed, main_context + 0x230, sizeof(changed));
      assert(std::memcmp(&original_projection, camera_object + 0xe0, sizeof(Matrix)) == 0);
      for (unsigned r = 0; r < 4; ++r) {
        assert(std::abs(changed.m[r][0] - original_projection.m[r][0] - 2 * frame.jitter[0] / 3840 * original_projection.m[r][3]) < 1.e-7f);
        assert(std::abs(changed.m[r][1] - original_projection.m[r][1] + 2 * frame.jitter[1] / 2160 * original_projection.m[r][3]) < 1.e-7f);
        assert(changed.m[r][2] == original_projection.m[r][2] && changed.m[r][3] == original_projection.m[r][3]);
      }
      std::thread producer([&] { BuildHook(renderer, nullptr, &a); });
      producer.join();
      assert(PrepareHook(renderer, nullptr, nullptr, nullptr, nullptr));
      std::thread newer([&] { BuildHook(renderer, nullptr, &b); });
      newer.join();
      assert(a.frame.id != b.frame.id);
      assert(a.frame.phase == n * 2 && b.frame.phase == n * 2 + 1);
      // Render the older job after the camera and CPU phase have advanced.
      std::thread consumer([&] {current_job=&a;ExecuteHook(nullptr,nullptr,nullptr,a.descriptor+0x18);current_job=&b;ExecuteHook(nullptr,nullptr,nullptr,b.descriptor+0x18); });
      consumer.join();
      assert(batches.empty());
    }
  }
  Configure({reinterpret_cast<uintptr_t>(renderer), reinterpret_cast<uintptr_t>(camera_object), 3840, 2160, 0, 0, false});
  PrepareHook(renderer, nullptr, nullptr, nullptr, nullptr);
  assert(direct_projection.main_view && !direct_projection.modified);
  assert(std::memcmp(main_context + 0x230, &original_projection, sizeof(Matrix)) == 0);
  assert(observations == 32 && tagged == consumed);
  VirtualFree(executable, 0, MEM_RELEASE);
  std::puts("PASS: engine projection jitter, x86 ABI/alignment, unchanged source/z/w, copied contexts, partial updates, queued older frames, MSAA footprint, AA off, unknown executable");
}
