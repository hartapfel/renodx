#define NOMINMAX
#include <d3d11_4.h>
#include <DirectXPackedVector.h>
#include <dxgi1_6.h>
#include <windows.h>
#include <wrl/client.h>
#include <cassert>
#include <cmath>
#include <iostream>
#include "../../presentation_client.hpp"
using namespace acbrotherhood::presentation;
using Microsoft::WRL::ComPtr;
int main(int argc, char** argv) {
  std::cout << std::unitbuf;
  try {
    WNDCLASSW wc{};
    wc.lpfnWndProc = DefWindowProcW;
    wc.hInstance = GetModuleHandleW(nullptr);
    wc.lpszClassName = L"UnifiedHelperTest";
    RegisterClassW(&wc);
    HWND window = CreateWindowW(wc.lpszClassName, L"Unified DLAA and FG regression", WS_POPUP, 0, 0, 1280, 720, nullptr, nullptr, wc.hInstance, nullptr);
    ShowWindow(window, SW_SHOW);
    SetForegroundWindow(window);
    ComPtr<ID3D11Device> device;
    ComPtr<ID3D11DeviceContext> context;
    Check(D3D11CreateDevice(nullptr, D3D_DRIVER_TYPE_HARDWARE, nullptr, 0, nullptr, 0, D3D11_SDK_VERSION, &device, nullptr, &context), Stage::device);
    unsigned total_aa = 0, total_fg = 0;
    for (unsigned round = 0; round < 3; ++round) {
      UINT width = round == 1 ? 960 : 1280, height = round == 1 ? 540 : 720;
      SetWindowPos(window, nullptr, 0, 0, width, height, SWP_NOACTIVATE | SWP_NOZORDER);
      D3D11_TEXTURE2D_DESC desc{};
      desc.Width = width;
      desc.Height = height;
      desc.MipLevels = desc.ArraySize = desc.SampleDesc.Count = 1;
      desc.Format = round == 1 ? DXGI_FORMAT_R10G10B10A2_UNORM : DXGI_FORMAT_B8G8R8A8_UNORM;
      desc.BindFlags = D3D11_BIND_RENDER_TARGET | D3D11_BIND_SHADER_RESOURCE;
      desc.MiscFlags = D3D11_RESOURCE_MISC_SHARED;
      ComPtr<ID3D11Texture2D> final_color;
      ComPtr<ID3D11RenderTargetView> final_rtv;
      Check(device->CreateTexture2D(&desc, nullptr, &final_color), Stage::sharing);
      Check(device->CreateRenderTargetView(final_color.Get(), nullptr, &final_rtv), Stage::sharing);
      ComPtr<ID3D11Texture2D> textures[4];
      ComPtr<ID3D11RenderTargetView> rtvs[4];
      acbrotherhood::dlaa::Packet aa;
      aa.width = width;
      aa.height = height;
      aa.generation = round + 1;
      uint64_t* handles[] = {&aa.color, &aa.motion, &aa.depth, &aa.output};
      for (unsigned i = 0; i < 4; ++i) {
        auto d = desc;
        d.Format = i == 2 ? DXGI_FORMAT_R32_FLOAT : DXGI_FORMAT_R16G16B16A16_FLOAT;
        Check(device->CreateTexture2D(&d, nullptr, &textures[i]), Stage::sharing);
        Check(device->CreateRenderTargetView(textures[i].Get(), nullptr, &rtvs[i]), Stage::sharing);
        ComPtr<IDXGIResource> resource;
        Check(textures[i].As(&resource), Stage::sharing);
        HANDLE handle = nullptr;
        Check(resource->GetSharedHandle(&handle), Stage::sharing);
        *handles[i] = uintptr_t(handle);
      }
      Client client;
      client.Start(device.Get(), desc, window, round == 1 ? DXGI_COLOR_SPACE_RGB_FULL_G2084_NONE_P2020 : DXGI_COLOR_SPACE_RGB_FULL_G22_NONE_P709, std::filesystem::absolute("build64-brotherhood-dx12/Release/renodx-asscreedbrotherhood-dx12.exe"), argc > 1, round == 0 ? 0 : 2, {1, 60});
      aa.adapter_low = client.packet->adapter_low;
      aa.adapter_high = client.packet->adapter_high;
      float vp[] = {1, 0, 0, 0, 0, float(width) / height, 0, 0, 0, 0, 1.0001f, -.10001f, 0, 0, 1, 0};
      std::copy(vp, vp + 16, aa.current_camera);
      for (unsigned i = 0; i < 4; ++i) aa.clip_to_previous[i * 5] = 1;
      acbrotherhood::frame_generation::Inputs fg;
      fg.width = width;
      fg.height = height;
      fg.window = uintptr_t(window);
      fg.generation = round + 1;
      fg.flags = 7;
      fg.hudless_format = desc.Format;
      std::copy(vp, vp + 16, fg.current_camera);
      std::copy(vp, vp + 16, fg.previous_camera);
      std::copy(aa.clip_to_previous, aa.clip_to_previous + 16, fg.clip_to_previous);
      fg.textures[0] = aa.motion;
      fg.textures[1] = aa.depth;
      ComPtr<IDXGIResource> final_resource;
      Check(final_color.As(&final_resource), Stage::sharing);
      HANDLE final_handle = nullptr;
      Check(final_resource->GetSharedHandle(&final_handle), Stage::sharing);
      fg.textures[2] = uintptr_t(final_handle);
      auto read_desc = desc;
      read_desc.Format = DXGI_FORMAT_R16G16B16A16_FLOAT;
      read_desc.Usage = D3D11_USAGE_STAGING;
      read_desc.CPUAccessFlags = D3D11_CPU_ACCESS_READ;
      read_desc.MiscFlags = read_desc.BindFlags = 0;
      ComPtr<ID3D11Texture2D> readback;
      Check(device->CreateTexture2D(&read_desc, nullptr, &readback), Stage::copy);
      for (unsigned f = 1; f <= 100; ++f) {
        MSG msg;
        while (PeekMessageW(&msg, nullptr, 0, 0, PM_REMOVE)) {
          TranslateMessage(&msg);
          DispatchMessageW(&msg);
        }
        // FG deliberately pauses for background windows. A command-line test
        // may lack foreground permission, so join that input queue briefly.
        if (GetAncestor(GetForegroundWindow(), GA_ROOT) != window) {
          const DWORD foreground_thread = GetWindowThreadProcessId(GetForegroundWindow(), nullptr);
          const bool attached = AttachThreadInput(GetCurrentThreadId(), foreground_thread, TRUE) != FALSE;
          SetForegroundWindow(window);
          if (attached) AttachThreadInput(GetCurrentThreadId(), foreground_thread, FALSE);
        }
        client.Timing(Command::begin_frame);
        client.Timing(Command::render_begin);
        const float color[] = {.3f, .2f, .1f, 1}, motion[] = {0, 0, 0, 1}, depth[] = {.95f, 0, 0, 0};
        context->ClearRenderTargetView(rtvs[0].Get(), color);
        context->ClearRenderTargetView(rtvs[1].Get(), motion);
        context->ClearRenderTargetView(rtvs[2].Get(), depth);
        context->ClearRenderTargetView(final_rtv.Get(), color);
        // Stand in for the completed DX9 event query before the legacy handoff.
        ComPtr<ID3D11Query> query;
        D3D11_QUERY_DESC q{D3D11_QUERY_EVENT, 0};
        Check(device->CreateQuery(&q, &query), Stage::copy);
        context->End(query.Get());
        while (context->GetData(query.Get(), nullptr, 0, 0) == S_FALSE) Sleep(0);
        aa.frame = {f, .125f, -.25f, 16.667f, f == 1 ? 1u : 0u};
        aa.render_preset = f < 30 ? 0 : f < 55 ? 6
                                    : f < 80   ? 11
                                               : 0;
        if (f == 60) aa.render_preset = 99;
        if (f == 70) client.Dlaa(&aa, true);
        client.Dlaa(&aa);
        if (f == 60) {
          assert(aa.state == acbrotherhood::dlaa::WorkerState::failed);
        } else {
          if (aa.state != acbrotherhood::dlaa::WorkerState::complete) {
            std::cout << "DLAA failed " << unsigned(aa.stage) << " code=" << aa.error << " frame=" << f << '\n';
            return 2;
          }
          assert(aa.completed_id == f && aa.backend == 12);
          ++total_aa;
          if (f % 10 == 0) {
            context->CopyResource(readback.Get(), textures[3].Get());
            D3D11_MAPPED_SUBRESOURCE mapped{};
            Check(context->Map(readback.Get(), 0, D3D11_MAP_READ, 0, &mapped), Stage::copy);
            auto p = reinterpret_cast<const DirectX::PackedVector::HALF*>(static_cast<const char*>(mapped.pData) + height / 2 * mapped.RowPitch) + width / 2 * 4;
            for (unsigned c = 0; c < 3; ++c) {
              float v = DirectX::PackedVector::XMConvertHalfToFloat(p[c]);
              assert(std::isfinite(v) && std::abs(v - color[c]) < .025f);
            }
            context->Unmap(readback.Get(), 0);
          }
        }
        fg.id = f;
        fg.reset = f == 1;
        fg.delta_ms = 16.667f;
        Check(client.Present(final_color.Get(), 0, 0, &fg), Stage::present);
        if (client.packet->generation_status == acbrotherhood::frame_generation::Status::active) {
          assert(client.packet->generated_present_count == 3);
          ++total_fg;
        }
        if (client.packet->generation_error) {
          std::cout << "FG error " << client.packet->generation_error << '\n';
          return 3;
        }
      }
      client.Dlaa(&aa, true);
      std::cout << "PASS round " << round << " AA=" << total_aa << " FG=" << total_fg << " process=" << GetProcessId(client.process.value) << '\n';
      client.Stop();
    }
    assert(total_aa == 297 && total_fg > 100);
    DestroyWindow(window);
    std::cout << "PASS unified DLAA/FG, SDR/HDR, resize/restart, preset reset, optional-AA failure, release and finite output\n";
  } catch (const Failure& e) {
    std::cerr << "FAIL stage=" << unsigned(e.stage) << " code=" << std::hex << e.code << '\n';
    return 1;
  }
}
