// Run in an isolated folder with ReShade as dxgi.dll and the Release addon.
// This synthetic renderer never launches or attaches to a game.
#define NOMINMAX
#include <windows.h>
#include <d3d9.h>
#include <wrl/client.h>
#include <algorithm>
#include <array>
#include <cassert>
#include <cstring>
#include <iostream>
#include <string_view>

using Microsoft::WRL::ComPtr;

int main(int argc, char** argv) {
  std::cout << std::unitbuf;
  assert(LoadLibraryW(L".\\dxgi.dll"));
  WNDCLASSW window_class{};
  window_class.lpfnWndProc = DefWindowProcW;
  window_class.hInstance = GetModuleHandleW(nullptr);
  window_class.lpszClassName = L"RenoDXCompressedTextureRegression";
  assert(RegisterClassW(&window_class));
  const HWND window = CreateWindowW(window_class.lpszClassName, L"Texture regression", WS_POPUP,
                                    0, 0, 64, 32, nullptr, nullptr, window_class.hInstance, nullptr);
  assert(window);
  ComPtr<IDirect3D9> api;
  api.Attach(Direct3DCreate9(D3D_SDK_VERSION));
  assert(api);
  D3DPRESENT_PARAMETERS parameters{};
  parameters.Windowed = TRUE;
  parameters.SwapEffect = D3DSWAPEFFECT_DISCARD;
  parameters.hDeviceWindow = window;
  parameters.BackBufferWidth = 64;
  parameters.BackBufferHeight = 32;
  parameters.BackBufferFormat = D3DFMT_X8R8G8B8;
  ComPtr<IDirect3DDevice9> device;
  assert(SUCCEEDED(api->CreateDevice(0, D3DDEVTYPE_HAL, window, D3DCREATE_HARDWARE_VERTEXPROCESSING,
                                    &parameters, &device)));
  ComPtr<IDirect3DDevice9Ex> extended;
  assert(SUCCEEDED(device.As(&extended)));
  if (argc > 1 && std::string_view(argv[1]) == "--expect-rejection") {
    ComPtr<IDirect3DTexture9> texture;
    const HRESULT result = device->CreateTexture(2, 16, 1, 0, D3DFMT_DXT5, D3DPOOL_MANAGED, &texture, nullptr);
    std::cout << "Original 2x16 DXT5 HRESULT=0x" << std::hex << result << '\n';
    assert(FAILED(result) && !texture);
    return 0;
  }
  for (unsigned iteration = 0; iteration < 3; ++iteration) {
    for (auto format : {D3DFMT_DXT1, D3DFMT_DXT3, D3DFMT_DXT5}) {
      for (const auto size : {std::array<UINT, 2>{2, 16}, {16, 2}, {1, 1}, {8, 16}}) {
        ComPtr<IDirect3DTexture9> texture;
        assert(SUCCEEDED(device->CreateTexture(size[0], size[1], 1, 0, format, D3DPOOL_MANAGED, &texture, nullptr)));
        D3DSURFACE_DESC desc{};
        assert(SUCCEEDED(texture->GetLevelDesc(0, &desc)));
        assert(desc.Width == std::max(4u, size[0]) && desc.Height == std::max(4u, size[1]));
        assert(desc.Format == format && texture->GetLevelCount() == 1);
        // Padding must not increase the number of encoded blocks or alter uploads.
        const UINT row_bytes = ((size[0] + 3) / 4) * (format == D3DFMT_DXT1 ? 8 : 16);
        const UINT rows = (size[1] + 3) / 4;
        D3DLOCKED_RECT locked{};
        assert(SUCCEEDED(texture->LockRect(0, &locked, nullptr, 0)));
        assert(locked.Pitch >= int(row_bytes));
        for (UINT row = 0; row < rows; ++row)
          std::memset(static_cast<unsigned char*>(locked.pBits) + row * locked.Pitch, 0x5a, row_bytes);
        assert(SUCCEEDED(texture->UnlockRect(0)));
        assert(SUCCEEDED(texture->LockRect(0, &locked, nullptr, D3DLOCK_READONLY)));
        for (UINT row = 0; row < rows; ++row) for (UINT byte = 0; byte < row_bytes; ++byte)
          assert(static_cast<unsigned char*>(locked.pBits)[row * locked.Pitch + byte] == 0x5a);
        assert(SUCCEEDED(texture->UnlockRect(0)));
      }
    }
    ComPtr<IDirect3DTexture9> rgba;
    assert(SUCCEEDED(device->CreateTexture(2, 16, 1, 0, D3DFMT_A8R8G8B8, D3DPOOL_MANAGED, &rgba, nullptr)));
    D3DSURFACE_DESC desc{};
    assert(SUCCEEDED(rgba->GetLevelDesc(0, &desc)) && desc.Width == 2 && desc.Height == 16);
    rgba.Reset();
    assert(SUCCEEDED(device->Reset(&parameters)));
  }
  std::cout << "PASS: BC1/BC2/BC3 dimensions, block uploads, ordinary RGBA and device resets\n";
  extended.Reset();
  device.Reset();
  api.Reset();
  DestroyWindow(window);
}
