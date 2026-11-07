// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#include "../lighting/graphics/tests/gpu.hpp"
#include "../clouds/gpu.hpp"
#include <chrono>

int main() {
  namespace gpu = hartapfelfx::clouds::gpu;
  GpuFixture fixture;
  gpu::UploadPool pool;
  std::array<uint32_t, 64> first, second;
  first.fill(0x12345678); second.fill(0x87654321);
  auto a = pool.Upload(fixture.device.Get(), first.data(), sizeof(first));
  auto b = pool.Upload(fixture.device.Get(), second.data(), sizeof(second));
  assert(a.object != b.object && pool.Size() == 2);
  auto readback = fixture.Buffer(sizeof(first) + sizeof(second), D3D12_HEAP_TYPE_READBACK);
  fixture.cmd->CopyBufferRegion(readback.Get(), 0, a.object.Get(), 0, sizeof(first));
  fixture.cmd->CopyBufferRegion(readback.Get(), sizeof(first), b.object.Get(), 0, sizeof(second));
  // A third recording must not overwrite either earlier recording's page.
  auto c = pool.Upload(fixture.device.Get(), second.data(), sizeof(second));
  assert(c.object != a.object && c.object != b.object && pool.Size() == 3);
  fixture.Submit();
  void* mapped = nullptr;
  Check(readback->Map(0, nullptr, &mapped));
  assert(std::memcmp(mapped, first.data(), sizeof(first)) == 0);
  assert(std::memcmp(static_cast<char*>(mapped) + sizeof(first), second.data(), sizeof(second)) == 0);
  readback->Unmap(0, nullptr);
  a = {}; b = {}; c = {};
  for (uint32_t i = 0; i < 1000; ++i) {
    auto page = pool.Upload(fixture.device.Get(), first.data(), sizeof(first));
    fixture.cmd->CopyBufferRegion(readback.Get(), 0, page.object.Get(), 0, sizeof(first));
    fixture.Submit();
  }
  assert(pool.Size() == 3);
  fixture.CheckMessages();
  constexpr unsigned iterations = 1000;
  const auto fresh_start = std::chrono::steady_clock::now();
  for (unsigned i = 0; i < iterations; ++i) {
    auto page = gpu::Upload(fixture.device.Get(), first.data(), sizeof(first));
  }
  const auto pooled_start = std::chrono::steady_clock::now();
  for (unsigned i = 0; i < iterations; ++i) {
    auto page = pool.Upload(fixture.device.Get(), first.data(), sizeof(first));
  }
  const auto end = std::chrono::steady_clock::now();
  std::cout << "Upload lifetime/readback passed; pages=" << pool.Size()
            << "; 1000 uploads fresh_us=" << std::chrono::duration_cast<std::chrono::microseconds>(pooled_start - fresh_start).count()
            << " pooled_us=" << std::chrono::duration_cast<std::chrono::microseconds>(end - pooled_start).count() << '\n';
}
