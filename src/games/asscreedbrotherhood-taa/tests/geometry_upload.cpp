// GPU ownership test for recycled native animation uploads. No game required.
#define NOMINMAX
#include <cassert>
#include <iostream>
#include "../taa_geometry.hpp"
using Microsoft::WRL::ComPtr;
using namespace acbrotherhood::taa;

int main() {
  WNDCLASSW wc{};
  wc.lpfnWndProc = DefWindowProcW;
  wc.hInstance = GetModuleHandleW(nullptr);
  wc.lpszClassName = L"GeometryUploadTest";
  RegisterClassW(&wc);
  HWND window = CreateWindowW(wc.lpszClassName, L"Geometry upload ownership", WS_POPUP,
                              0, 0, 128, 128, nullptr, nullptr, wc.hInstance, nullptr);
  assert(window);
  ComPtr<IDirect3D9Ex> api;
  ComPtr<IDirect3DDevice9Ex> device;
  assert(SUCCEEDED(Direct3DCreate9Ex(D3D_SDK_VERSION, &api)));
  D3DPRESENT_PARAMETERS pp{};
  pp.Windowed = TRUE; pp.hDeviceWindow = window;
  pp.BackBufferWidth = pp.BackBufferHeight = 128;
  pp.BackBufferFormat = D3DFMT_X8R8G8B8;
  pp.SwapEffect = D3DSWAPEFFECT_DISCARD;
  assert(SUCCEEDED(api->CreateDeviceEx(0, D3DDEVTYPE_HAL, window, D3DCREATE_HARDWARE_VERTEXPROCESSING,
                                      &pp, nullptr, &device)));
  struct Vertex { float x, y, z, w; DWORD color; };
  ComPtr<IDirect3DVertexBuffer9> source;
  assert(SUCCEEDED(device->CreateVertexBuffer(3 * sizeof(Vertex), D3DUSAGE_DYNAMIC | D3DUSAGE_WRITEONLY,
                                              0, D3DPOOL_DEFAULT, &source, nullptr)));
  auto cache = std::make_unique<GeometryCache>();
  const auto capture = [&](unsigned index) {
    void* mapping = nullptr;
    assert(SUCCEEDED(source->Lock(0, 0, &mapping, D3DLOCK_DISCARD)));
    cache->Map(source.Get(), 0, 3 * sizeof(Vertex), mapping, true, &mapping);
    const float x = float(index % 8 * 16) - .5f, y = float(index / 8 * 16) - .5f;
    const DWORD color = D3DCOLOR_XRGB(32 + index * 3, 96, 160);
    const Vertex triangle[] = {{x, y, 0, 1, color}, {x + 16, y, 0, 1, color}, {x, y + 16, 0, 1, color}};
    std::memcpy(mapping, triangle, sizeof(triangle));
    cache->Unmap(uintptr_t(source.Get()));
    assert(SUCCEEDED(source->Unlock()));
    return cache->Snapshot(device.Get(), source.Get());
  };

  // Current and previous poses must never lease the same GPU buffer.
  auto old = capture(1), current = capture(2);
  assert(old && current && old->vertices != current->vertices && old->data != current->data);
  const auto old_bytes = old->data;
  auto newer = capture(3);
  assert(newer && newer->vertices != old->vertices && newer->vertices != current->vertices);
  assert(old->data == old_bytes && cache->gpu_bytes->load() == 9 * sizeof(Vertex));
  old.reset(); current.reset(); newer.reset();
  assert(cache->gpu_bytes->load() == 0 && cache->uploads->created == 3);

  device->SetFVF(D3DFVF_XYZRHW | D3DFVF_DIFFUSE);
  device->SetRenderState(D3DRS_LIGHTING, FALSE);
  device->SetRenderState(D3DRS_ZENABLE, FALSE);
  device->SetRenderState(D3DRS_CULLMODE, D3DCULL_NONE);
  assert(SUCCEEDED(device->Clear(0, nullptr, D3DCLEAR_TARGET, 0, 1, 0)));
  assert(SUCCEEDED(device->BeginScene()));
  for (unsigned i = 0; i < 64; ++i) {
    auto snapshot = capture(i);
    assert(snapshot);
    assert(SUCCEEDED(device->SetStreamSource(0, snapshot->vertices.Get(), 0, sizeof(Vertex))));
    assert(SUCCEEDED(device->DrawPrimitive(D3DPT_TRIANGLELIST, 0, 1)));
    // Release immediately and reuse without any CPU/GPU completion wait. Each
    // queued draw must retain the version that existed at its DISCARD upload.
  }
  assert(SUCCEEDED(device->EndScene()));
  std::cout << "created=" << cache->uploads->created << " reused=" << cache->uploads->reused
            << " cached=" << cache->uploads->cached_bytes << " active=" << cache->gpu_bytes->load() << std::endl;
  assert(cache->uploads->created == 3 && cache->uploads->reused == 64);
  assert(cache->uploads->cached_bytes == 9 * sizeof(Vertex));
  ComPtr<IDirect3DSurface9> target, readback;
  assert(SUCCEEDED(device->GetRenderTarget(0, &target)));
  assert(SUCCEEDED(device->CreateOffscreenPlainSurface(128, 128, D3DFMT_X8R8G8B8,
                                                       D3DPOOL_SYSTEMMEM, &readback, nullptr)));
  assert(SUCCEEDED(device->GetRenderTargetData(target.Get(), readback.Get())));
  D3DLOCKED_RECT pixels{};
  assert(SUCCEEDED(readback->LockRect(&pixels, nullptr, D3DLOCK_READONLY)));
  for (unsigned i = 0; i < 64; ++i) {
    auto* row = reinterpret_cast<const DWORD*>(static_cast<const char*>(pixels.pBits) + (i / 8 * 16 + 4) * pixels.Pitch);
    assert((row[i % 8 * 16 + 4] & 0xffffff) == (D3DCOLOR_XRGB(32 + i * 3, 96, 160) & 0xffffff));
  }
  readback->UnlockRect();

  // Mixed sizes/large uploads cannot grow the cache beyond its fixed limit.
  for (unsigned i = 0; i < 80; ++i) {
    ComPtr<IDirect3DVertexBuffer9> buffer;
    const UINT size = (i + 1) * 2048;
    assert(SUCCEEDED(cache->uploads->Acquire(device.Get(), size, std::addressof(buffer))));
    cache->uploads->Recycle(std::addressof(buffer), size);
    assert(cache->uploads->cached_bytes <= 4 * 1024 * 1024);
  }
  cache.reset(); source.Reset(); target.Reset(); readback.Reset();
  device->SetStreamSource(0, nullptr, 0, 0);
  assert(SUCCEEDED(device->ResetEx(&pp, nullptr)));
  DestroyWindow(window);
  std::cout << "PASS immutable live poses, 64 queued DISCARD draws, buffer reuse, bounded cache and reset\n";
}
