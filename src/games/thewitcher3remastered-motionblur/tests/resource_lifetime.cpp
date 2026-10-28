/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#include <cassert>
#include <iostream>
#include "../motion_resources.hpp"
using namespace witcher::motion;
template <typename Pool>
void VerifyPool() {
  ComPtr<ID3D12Device> dev;
  assert(SUCCEEDED(D3D12CreateDevice(nullptr,D3D_FEATURE_LEVEL_12_0,IID_PPV_ARGS(&dev))));
  D3D12_COMMAND_QUEUE_DESC desc{};
  ComPtr<ID3D12CommandQueue> native;
  assert(SUCCEEDED(dev->CreateCommandQueue(&desc,IID_PPV_ARGS(&native))));
  auto queue=std::make_shared<Queue>();queue->native=native.Get();
  assert(SUCCEEDED(dev->CreateFence(0,D3D12_FENCE_FLAG_NONE,IID_PPV_ARGS(&queue->fence))));
  ComPtr<ID3D12Fence> gate;
  assert(SUCCEEDED(dev->CreateFence(0,D3D12_FENCE_FLAG_NONE,IID_PPV_ARGS(&gate))));
  assert(SUCCEEDED(native->Wait(gate.Get(),1)));
  Pool pool;
  assert(!pool.Acquire(dev.Get(), 0));
  auto first=pool.Acquire(dev.Get(),4<<20);
  assert(first);
  assert(bool(first->constants) == (Pool::UPLOAD_BYTES != 0));
  auto* first_resource=first->scratch.Get();
  std::vector<std::shared_ptr<Allocation>> recording{first};
  std::vector<std::shared_ptr<Queue>> queues{queue};
  pool.Retire(&recording,&queues);
  pool.Collect(true);
  assert(pool.bytes==(4<<20)+Pool::UPLOAD_BYTES && !first->Ready());
  auto second=pool.Acquire(dev.Get(),4<<20);
  assert(second && second->scratch.Get()!=first_resource);
  assert(!pool.Acquire(dev.Get(),Pool::LIMIT));
  assert(SUCCEEDED(gate->Signal(1)));
  HANDLE event=CreateEvent(nullptr,FALSE,FALSE,nullptr);
  assert(event);
  assert(SUCCEEDED(queue->fence->SetEventOnCompletion(queue->serial,event)));
  assert(WaitForSingleObject(event,10000)==WAIT_OBJECT_0);
  auto reused=pool.Acquire(dev.Get(),4<<20);
  assert(reused==first);
  recording={reused,second};pool.Retire(&recording,&queues);
  reused.reset();first.reset();second.reset();pool.Collect(true);assert(pool.bytes==0);
  // Model thousands of menu command-list replacements, varying active sizes,
  // never-submitted recordings, resolution growth and fences on submitted work.
  for(unsigned iteration=0;iteration<3000;++iteration) {
    const uint64_t size=(iteration%7==0?8:2)<<20;
    auto a=pool.Acquire(dev.Get(),size);assert(a);
    recording={a};queues=iteration%3?std::vector{queue}:std::vector<std::shared_ptr<Queue>>{};
    pool.Retire(&recording,&queues);
    if(iteration%3) {
      assert(SUCCEEDED(queue->fence->SetEventOnCompletion(queue->serial,event)));
      assert(WaitForSingleObject(event,10000)==WAIT_OBJECT_0);
    }
    ++pool.frame;pool.Collect();assert(pool.bytes<(32<<20));
  }
  pool.frame+=120;pool.Collect();assert(pool.bytes==0);
  CloseHandle(event);
  std::cout<<"PASS 3000 menu lifecycles; blocked-fence retention, safe reuse, hard budget, zero idle bytes; peak="<<pool.peak_bytes<<"\n";
}

int main() {
  VerifyPool<ResourcePool>();
  VerifyPool<renodx::utils::d3d12_resource_pool::ResourcePool<384ull << 20>>();
}
