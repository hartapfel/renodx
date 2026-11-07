// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#include <barrier>
#include <chrono>
#include <iostream>
#include <stdexcept>
#include <thread>
#include <vector>
#include <wrl/client.h>
#include "../descriptor_cache.hpp"
#include "../lighting/graphics/rendering/bindings.hpp"

namespace cache = hartapfelfx::descriptors;
namespace api = reshade::api;
using Microsoft::WRL::ComPtr;

int main() {
  try {
    cache::Slot source;
    std::atomic_bool finished{false}, corrupt{false};
    std::thread writer([&] {
      for (uint64_t index = 1; index <= 200000; ++index) {
        cache::Value value;
        value.type = api::descriptor_type::constant_buffer;
        value.buffer_range = {{index}, index * 256, index * 4096};
        source.Write(value);
      }
      finished = true;
    });
    std::array<std::thread, 4> readers;
    for (auto& reader : readers) {
      reader = std::thread([&] {
        while (!finished.load()) {
          const auto value = source.Read();
          if (value.type != api::descriptor_type::constant_buffer) continue;
          if (value.buffer_range.offset != value.buffer_range.buffer.handle * 256
              || value.buffer_range.size != value.buffer_range.buffer.handle * 4096) corrupt = true;
        }
      });
    }
    writer.join();
    for (auto& reader : readers) reader.join();
    if (corrupt) throw std::runtime_error("Torn descriptor snapshot under concurrent rewrite");

    constexpr size_t workers = 8, width = 16, iterations = 50000;
    std::array<cache::Value, width> inputs;
    for (uint64_t index = 0; index < width; ++index) {
      inputs[index].type = api::descriptor_type::constant_buffer;
      inputs[index].buffer_range = {{index + 1}, index * 256, 4096};
    }
    std::array<cache::Slot, workers * width> outputs;
    std::array<cache::Value, workers * width> legacy;
    std::shared_mutex legacy_mutex;
    const auto measure = [&](bool serialized) {
      std::barrier start(workers + 1);
      std::vector<std::thread> threads;
      for (size_t worker = 0; worker < workers; ++worker) {
        threads.emplace_back([&, worker] {
          start.arrive_and_wait();
          for (size_t iteration = 0; iteration < iterations; ++iteration) {
            if (serialized) {
              std::unique_lock lock(legacy_mutex);
              std::copy(inputs.begin(), inputs.end(), legacy.begin() + worker * width);
            } else {
              for (size_t item = 0; item < width; ++item) outputs[worker * width + item].Write(inputs[item]);
            }
          }
        });
      }
      const auto before = std::chrono::steady_clock::now();
      start.arrive_and_wait();
      for (auto& thread : threads) thread.join();
      return std::chrono::duration_cast<std::chrono::microseconds>(std::chrono::steady_clock::now() - before).count();
    };
    const auto serialized_us = measure(true);
    const auto independent_us = measure(false);
    for (size_t worker = 0; worker < workers; ++worker) {
      for (size_t item = 0; item < width; ++item) {
        const auto value = outputs[worker * width + item].Read();
        if (value.type != inputs[item].type || value.buffer_range.buffer != inputs[item].buffer_range.buffer
            || value.buffer_range.offset != inputs[item].buffer_range.offset || value.buffer_range.size != 4096) {
          throw std::runtime_error("Independent recording workers lost descriptor metadata");
        }
      }
    }
    std::cout << "PASS concurrent descriptor snapshots; 8-worker copy microbenchmark: serialized "
              << serialized_us << " us, independent " << independent_us << " us (not gameplay FPS)\n";

    ComPtr<ID3D12Device> device;
    if (FAILED(D3D12CreateDevice(nullptr, D3D_FEATURE_LEVEL_12_0, IID_PPV_ARGS(&device)))) {
      throw std::runtime_error("D3D12 device unavailable");
    }
    ComPtr<ID3D12DescriptorHeap> heap;
    const D3D12_DESCRIPTOR_HEAP_DESC desc{D3D12_DESCRIPTOR_HEAP_TYPE_CBV_SRV_UAV, 16};
    if (FAILED(device->CreateDescriptorHeap(&desc, IID_PPV_ARGS(&heap)))) throw std::runtime_error("Heap creation failed");
    auto directory = std::make_shared<cache::Directory>();
    const uint64_t handle = reinterpret_cast<uint64_t>(heap.Get());
    directory->heaps[handle] = std::make_shared<cache::Heap>();
    auto* lifetime = new cache::HeapLifetime();
    lifetime->directory = directory;
    lifetime->handle = handle;
    if (FAILED(heap->SetPrivateDataInterface(__uuidof(cache::HeapLifetime), lifetime))) {
      throw std::runtime_error("Heap lifetime registration failed");
    }
    lifetime->Release();
    heap.Reset();
    if (!directory->heaps.empty() || directory->revision.load() != 1) {
      throw std::runtime_error("Destroyed native heap retained stale descriptor identity");
    }
    witcher3graphics::bindings::RootState roots;
    roots.Select({1});
    roots.Argument(63)->constant_valid = uint64_t(1) << 63;
    roots.Argument(63)->constants[63] = 0x1234;
    roots.Select({2});
    if (roots.valid_arguments || roots.Argument(63)->constant_valid) {
      throw std::runtime_error("Root signature change retained stale partial constants");
    }
    std::cout << "PASS native heap destruction and root-signature invalidation\n";
  } catch (const std::exception& error) {
    std::cerr << error.what() << '\n';
    return 1;
  }
}
