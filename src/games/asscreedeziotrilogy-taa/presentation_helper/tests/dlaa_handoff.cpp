// Native DX9 shared-input ownership and DLAA handoff timing regression.
#define NOMINMAX
#include <d3d9.h>
#include <DirectXPackedVector.h>
#include <cassert>
#include <chrono>
#include <cmath>
#include <iostream>
#include "../../presentation_client.hpp"
using namespace acbrotherhood::presentation;
using Microsoft::WRL::ComPtr;
using Clock = std::chrono::steady_clock;

int main(int argc, char** argv) {
  std::cout << std::unitbuf;
  try {
    const bool validation = argc > 2;
    WNDCLASSW wc{};
    wc.lpfnWndProc = DefWindowProcW;
    wc.hInstance = GetModuleHandleW(nullptr);
    wc.lpszClassName = L"DlaaHandoffTest";
    RegisterClassW(&wc);
    HWND window = CreateWindowW(wc.lpszClassName, L"DX9 DLAA handoff test", WS_POPUP,
                                0, 0, 1280, 720, nullptr, nullptr, wc.hInstance, nullptr);
    assert(window);
    ComPtr<IDirect3D9Ex> d3d9;
    ComPtr<IDirect3DDevice9Ex> native;
    Check(Direct3DCreate9Ex(D3D_SDK_VERSION, &d3d9), Stage::device);
    D3DPRESENT_PARAMETERS pp{};
    pp.Windowed = TRUE;
    pp.hDeviceWindow = window;
    pp.BackBufferWidth = pp.BackBufferHeight = 64;
    pp.BackBufferFormat = D3DFMT_X8R8G8B8;
    pp.SwapEffect = D3DSWAPEFFECT_DISCARD;
    pp.PresentationInterval = D3DPRESENT_INTERVAL_IMMEDIATE;
    Check(d3d9->CreateDeviceEx(0, D3DDEVTYPE_HAL, window,
                              D3DCREATE_HARDWARE_VERTEXPROCESSING | D3DCREATE_FPU_PRESERVE,
                              &pp, nullptr, &native), Stage::device);
    ComPtr<IDirect3DQuery9> query;
    Check(native->CreateQuery(D3DQUERYTYPE_EVENT, &query), Stage::gpu_wait);
    ComPtr<ID3D11Device> device;
    ComPtr<ID3D11DeviceContext> context;
    Check(D3D11CreateDevice(nullptr, D3D_DRIVER_TYPE_HARDWARE, nullptr, 0, nullptr, 0,
                            D3D11_SDK_VERSION, &device, nullptr, &context), Stage::device);
    for (unsigned round = 0; round < 2; ++round) {
      const UINT width = round ? 3840 : 1280, height = round ? 2160 : 720;
      D3D11_TEXTURE2D_DESC desc{};
      desc.Width = width; desc.Height = height;
      desc.MipLevels = desc.ArraySize = desc.SampleDesc.Count = 1;
      desc.Format = DXGI_FORMAT_B8G8R8A8_UNORM;
      desc.BindFlags = D3D11_BIND_RENDER_TARGET | D3D11_BIND_SHADER_RESOURCE;
      ComPtr<ID3D11Texture2D> final_color;
      ComPtr<ID3D11RenderTargetView> final_rtv;
      Check(device->CreateTexture2D(&desc, nullptr, &final_color), Stage::sharing);
      Check(device->CreateRenderTargetView(final_color.Get(), nullptr, &final_rtv), Stage::sharing);
      const float black[] = {0, 0, 0, 1};
      context->ClearRenderTargetView(final_rtv.Get(), black);
      acbrotherhood::dlaa::Packet aa;
      aa.width = width; aa.height = height; aa.generation = round + 1;
      ComPtr<IDirect3DTexture9> textures[4];
      ComPtr<IDirect3DSurface9> surfaces[4];
      uint64_t* handles[] = {&aa.color, &aa.motion, &aa.depth, &aa.output};
      for (unsigned i = 0; i < 4; ++i) {
        HANDLE handle = nullptr;
        Check(native->CreateTexture(width, height, 1, D3DUSAGE_RENDERTARGET,
                                     i == 2 ? D3DFMT_R32F : D3DFMT_A16B16G16R16F,
                                     D3DPOOL_DEFAULT, &textures[i], &handle), Stage::sharing);
        *handles[i] = uintptr_t(handle);
        Check(textures[i]->GetSurfaceLevel(0, &surfaces[i]), Stage::sharing);
      }
      ComPtr<ID3D11Texture2D> output, readback;
      Check(device->OpenSharedResource(reinterpret_cast<HANDLE>(uintptr_t(aa.output)), IID_PPV_ARGS(&output)), Stage::sharing);
      auto read_desc = desc;
      read_desc.Width = read_desc.Height = 1;
      read_desc.Format = DXGI_FORMAT_R16G16B16A16_FLOAT;
      read_desc.Usage = D3D11_USAGE_STAGING;
      read_desc.CPUAccessFlags = D3D11_CPU_ACCESS_READ;
      read_desc.BindFlags = 0;
      Check(device->CreateTexture2D(&read_desc, nullptr, &readback), Stage::copy);
      Client client;
      client.Start(device.Get(), desc, window, DXGI_COLOR_SPACE_RGB_FULL_G22_NONE_P709,
                   std::filesystem::absolute(argc > 1 ? argv[1] : "build64-eziotrilogy-dx12/Release/renodx-asscreedeziotrilogy-dx12.exe"), validation);
      aa.adapter_low = client.packet->adapter_low; aa.adapter_high = client.packet->adapter_high;
      const float vp[] = {1, 0, 0, 0, 0, float(width) / height, 0, 0, 0, 0, 1.0001f, -.10001f, 0, 0, 1, 0};
      std::copy(vp, vp + 16, aa.current_camera);
      for (unsigned i = 0; i < 4; ++i) aa.clip_to_previous[i * 5] = 1;
      std::vector<double> handoff, input_wait;
      for (unsigned f = 1; f <= 150; ++f) {
        client.Timing(Command::begin_frame);
        client.Timing(Command::render_begin);
        aa.frame = {f, .125f, -.25f, 16.667f, f == 1 || f % 25 == 0 ? 1u : 0u};
        // Change a full-screen marker at history resets. A stale shared input
        // then produces the wrong color even when its frame ID looks correct.
        const unsigned red = f / 25 % 2 ? 160 : 64;
        // Deliberately send the command before writing a changed input. The
        // GPU readiness fence must prevent both early reads and early replies.
        const bool delayed = validation && f % 25 == 0;
        if (delayed) {
          client.BeginDlaa(aa);
          Sleep(5);
          assert(WaitForSingleObject(client.reply.value, 0) == WAIT_TIMEOUT);
        }
        const auto start = Clock::now();
        Check(native->BeginScene(), Stage::copy);
        for (unsigned i = 0; i < 3; ++i) {
          Check(native->SetRenderTarget(0, surfaces[i].Get()), Stage::copy);
          Check(native->Clear(0, nullptr, D3DCLEAR_TARGET,
                              i == 0 ? D3DCOLOR_ARGB(255, red, 96, 32) : i == 1 ? 0xff000000 : 0xffffffff,
                              1.f, 0), Stage::copy);
        }
        Check(native->EndScene(), Stage::copy);
        Check(query->Issue(D3DISSUE_END), Stage::gpu_wait);
        HRESULT completion = query->GetData(nullptr, 0, D3DGETDATA_FLUSH);
        Check(completion, Stage::gpu_wait);
        if (!delayed) client.BeginDlaa(aa);
        const ULONGLONG deadline = GetTickCount64() + 2000;
        while (completion == S_FALSE) {
          if (GetTickCount64() >= deadline) throw Failure{Stage::gpu_wait, WAIT_TIMEOUT};
          SwitchToThread();
          completion = query->GetData(nullptr, 0, 0);
          Check(completion, Stage::gpu_wait);
        }
        const auto ready = Clock::now();
        client.FinishDlaa(&aa);
        const auto done = Clock::now();
        if (aa.state != acbrotherhood::dlaa::WorkerState::complete)
          throw Failure{Stage::copy, aa.error};
        assert(aa.completed_id == f && aa.backend == 12);
        if (f > 30) {
          handoff.push_back(std::chrono::duration<double, std::milli>(done - start).count());
          input_wait.push_back(std::chrono::duration<double, std::milli>(ready - start).count());
        }
        if (f % 25 == 0) {
          const D3D11_BOX box{width / 2, height / 2, 0, width / 2 + 1, height / 2 + 1, 1};
          context->CopySubresourceRegion(readback.Get(), 0, 0, 0, 0, output.Get(), 0, &box);
          D3D11_MAPPED_SUBRESOURCE mapped{};
          Check(context->Map(readback.Get(), 0, D3D11_MAP_READ, 0, &mapped), Stage::copy);
          auto* pixel = static_cast<const DirectX::PackedVector::HALF*>(mapped.pData);
          const float expected[] = {red / 255.f, 96 / 255.f, 32 / 255.f};
          for (unsigned c = 0; c < 3; ++c) {
            float value = DirectX::PackedVector::XMConvertHalfToFloat(pixel[c]);
            assert(std::isfinite(value) && std::abs(value - expected[c]) < .025f);
          }
          context->Unmap(readback.Get(), 0);
        }
        Check(client.Present(final_color.Get(), 0, 0), Stage::present);
      }
      std::sort(handoff.begin(), handoff.end());
      std::sort(input_wait.begin(), input_wait.end());
      std::cout << width << 'x' << height << " handoff_ms median=" << handoff[handoff.size() / 2]
                << " p95=" << handoff[handoff.size() * 95 / 100]
                << " input_wait_ms=" << input_wait[input_wait.size() / 2] << '\n';
      if (validation) {
        // Cancellation before native readiness must terminate our worker,
        // never release textures while it is still waiting to consume them.
        aa.frame.id++;
        client.BeginDlaa(aa);
        Sleep(20);
        assert(WaitForSingleObject(client.reply.value, 0) == WAIT_TIMEOUT);
        Handle worker;
        assert(DuplicateHandle(GetCurrentProcess(), client.process.value, GetCurrentProcess(),
                               &worker.value, SYNCHRONIZE, FALSE, 0));
        client.Stop();
        assert(WaitForSingleObject(worker.value, 0) == WAIT_OBJECT_0);
      } else {
        client.Dlaa(&aa, true);
      }
      client.Stop();
    }
    DestroyWindow(window);
    std::cout << "PASS native DX9 inputs, current-frame markers, helper restart and 4K output\n";
  } catch (const Failure& e) {
    std::cerr << "FAIL stage=" << unsigned(e.stage) << " code=" << std::hex << e.code << '\n';
    return 1;
  }
}
