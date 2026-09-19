/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#include <windows.h>
#include <d3d11_4.h>
#include <d3d12.h>
#include <d3d12sdklayers.h>
#include <dxgi1_6.h>
#include <wrl/client.h>
#include <array>
#include <cstdlib>
#include <fstream>
#include <vector>
#include <memory>
#include "../dlaa_handles.hpp"
#include "../presentation_protocol.hpp"
#include "./fg_import.hpp"
#include "./streamline.hpp"
#include "./dlaa.hpp"
#include "./overlay_input.hpp"

using namespace acbrotherhood::presentation;
using acbrotherhood::dlaa::Handle;
using Microsoft::WRL::ComPtr;
namespace {
struct Window {
  HWND value = nullptr;
  ~Window() { if (value) DestroyWindow(value); }
};
void Run(Packet* packet, HANDLE request, HANDLE reply, HANDLE parent, HANDLE source_fence_handle, std::ofstream* log) {
  if (packet->magic != kMagic || packet->version != kProtocol) {
    *log << "Addon/helper protocol mismatch: received=" << packet->version << " expected=" << kProtocol << std::endl;
    throw Failure{Stage::protocol, ERROR_REVISION_MISMATCH};
  }
  if (!packet->width || !packet->height
      || uint64_t(packet->width) * packet->height > 8388608 || packet->validation > 1 || packet->generation_requested > 5
      || packet->pacing.reflex_mode > 2 || packet->pacing.render_fps > 1000)
    throw Failure{Stage::protocol, ERROR_INVALID_DATA};
  const auto format = DXGI_FORMAT(packet->format);
  const auto color_space = DXGI_COLOR_SPACE_TYPE(packet->color_space);
  const bool rgba8 = format == DXGI_FORMAT_R8G8B8A8_UNORM || format == DXGI_FORMAT_B8G8R8A8_UNORM;
  if (!((rgba8 && color_space == DXGI_COLOR_SPACE_RGB_FULL_G22_NONE_P709)
        || (format == DXGI_FORMAT_R10G10B10A2_UNORM && color_space == DXGI_COLOR_SPACE_RGB_FULL_G2084_NONE_P2020)
        || (format == DXGI_FORMAT_R16G16B16A16_FLOAT && color_space == DXGI_COLOR_SPACE_RGB_FULL_G10_NONE_P709)))
    throw Failure{Stage::swapchain, ERROR_NOT_SUPPORTED};
  const HWND game_window = reinterpret_cast<HWND>(uintptr_t(packet->window));
  DWORD window_process = 0;
  GetWindowThreadProcessId(game_window, &window_process);
  if (!IsWindow(game_window) || window_process != GetProcessId(parent))
    throw Failure{Stage::window, ERROR_INVALID_WINDOW_HANDLE};

  acbrotherhood::frame_generation::Streamline streamline;
  streamline.Initialize(packet->generation_requested != 0, log);
  DisplayPolicy display_policy(parent);
  display_policy.Start(game_window);
  streamline.display = &display_policy;
  if (packet->validation) {
    ComPtr<ID3D12Debug> debug;
    if (SUCCEEDED(D3D12GetDebugInterface(IID_PPV_ARGS(&debug)))) debug->EnableDebugLayer();
  }
  ComPtr<IDXGIFactory4> factory;
  Check(streamline.create_factory(0, IID_PPV_ARGS(&factory)), Stage::adapter);
  ComPtr<IDXGIAdapter> adapter;
  const LUID luid{packet->adapter_low, packet->adapter_high};
  Check(factory->EnumAdapterByLuid(luid, IID_PPV_ARGS(&adapter)), Stage::adapter);
  ComPtr<ID3D11Device> bridge;
  ComPtr<ID3D11DeviceContext> bridge_context;
  Check(D3D11CreateDevice(adapter.Get(), D3D_DRIVER_TYPE_UNKNOWN, nullptr, 0, nullptr, 0,
                         D3D11_SDK_VERSION, &bridge, nullptr, &bridge_context), Stage::device);
  ComPtr<ID3D11Device5> bridge5;
  ComPtr<ID3D11DeviceContext4> context4;
  Check(bridge.As(&bridge5), Stage::device); Check(bridge_context.As(&context4), Stage::device);
  ComPtr<ID3D12Device> device;
  Check(streamline.create_device(adapter.Get(), D3D_FEATURE_LEVEL_11_0, IID_PPV_ARGS(&device)), Stage::device);
  streamline.Attach(device.Get(), factory.Get(), luid);
  ComPtr<ID3D12InfoQueue> diagnostics;
  if (packet->validation) device.As(&diagnostics);
  D3D12_COMMAND_QUEUE_DESC queue_desc{};
  queue_desc.Type = D3D12_COMMAND_LIST_TYPE_DIRECT;
  ComPtr<ID3D12CommandQueue> queue;
  Check(device->CreateCommandQueue(&queue_desc, IID_PPV_ARGS(&queue)), Stage::device);
  ComPtr<ID3D11Texture2D> source;
  Check(bridge->OpenSharedResource(reinterpret_cast<HANDLE>(uintptr_t(packet->source_texture)), IID_PPV_ARGS(&source)), Stage::sharing);
  D3D11_TEXTURE2D_DESC source_desc{}; source->GetDesc(&source_desc);
  if (source_desc.Width != packet->width || source_desc.Height != packet->height || source_desc.Format != format
      || source_desc.SampleDesc.Count != 1 || source_desc.ArraySize != 1 || source_desc.MipLevels != 1)
    throw Failure{Stage::sharing, ERROR_INVALID_DATA};
  ComPtr<ID3D11Fence> source_fence;
  Check(bridge5->OpenSharedFence(source_fence_handle, IID_PPV_ARGS(&source_fence)), Stage::sharing);

  D3D12_HEAP_PROPERTIES heap{}; heap.Type = D3D12_HEAP_TYPE_DEFAULT;
  D3D12_RESOURCE_DESC resource{};
  resource.Dimension = D3D12_RESOURCE_DIMENSION_TEXTURE2D;
  resource.Width = packet->width; resource.Height = packet->height;
  resource.DepthOrArraySize = resource.MipLevels = 1; resource.Format = format;
  resource.SampleDesc.Count = 1;
  resource.Flags = D3D12_RESOURCE_FLAG_ALLOW_SIMULTANEOUS_ACCESS | D3D12_RESOURCE_FLAG_ALLOW_RENDER_TARGET;
  ComPtr<ID3D12Resource> input;
  Check(device->CreateCommittedResource(&heap, D3D12_HEAP_FLAG_SHARED, &resource, D3D12_RESOURCE_STATE_COMMON,
                                       nullptr, IID_PPV_ARGS(&input)), Stage::sharing);
  Handle input_handle;
  Check(device->CreateSharedHandle(input.Get(), nullptr, GENERIC_ALL, nullptr, &input_handle.value), Stage::sharing);
  ComPtr<ID3D11Texture2D> input11;
  Check(bridge5->OpenSharedResource1(input_handle.value, IID_PPV_ARGS(&input11)), Stage::sharing);
  ComPtr<ID3D12Fence> fence;
  Check(device->CreateFence(0, D3D12_FENCE_FLAG_SHARED, IID_PPV_ARGS(&fence)), Stage::sharing);
  Handle fence_handle, complete(CreateEventW(nullptr, FALSE, FALSE, nullptr));
  if (!complete.value) throw Failure{Stage::gpu_wait, GetLastError()};
  Check(device->CreateSharedHandle(fence.Get(), nullptr, GENERIC_ALL, nullptr, &fence_handle.value), Stage::sharing);
  ComPtr<ID3D11Fence> fence11;
  Check(bridge5->OpenSharedFence(fence_handle.value, IID_PPV_ARGS(&fence11)), Stage::sharing);

  // An HWND can have only one flip swapchain. Keep the game's input/focus HWND
  // and give the x64 presenter its own disabled child canvas. Match parent DPI
  // awareness; the child never takes keyboard or mouse focus.
  SetThreadDpiAwarenessContext(GetWindowDpiAwarenessContext(game_window));
  WNDCLASSW wc{}; wc.hInstance = GetModuleHandleW(nullptr);
  wc.lpfnWndProc = DefWindowProcW; wc.lpszClassName = L"RenoDXBrotherhoodDX12Output";
  if (!RegisterClassW(&wc) && GetLastError() != ERROR_CLASS_ALREADY_EXISTS) throw Failure{Stage::window, GetLastError()};
  Window window;
  window.value = CreateWindowExW(WS_EX_NOACTIVATE | WS_EX_NOPARENTNOTIFY, wc.lpszClassName, L"RenoDX DX12 output", WS_CHILD | WS_DISABLED,
                                 0, 0, packet->width, packet->height, game_window, nullptr, wc.hInstance, nullptr);
  if (!window.value) throw Failure{Stage::window, GetLastError()};
  OverlayInput overlay_input(window.value);
  BOOL tearing = FALSE;
  ComPtr<IDXGIFactory5> factory5;
  if (SUCCEEDED(factory.As(&factory5))) factory5->CheckFeatureSupport(DXGI_FEATURE_PRESENT_ALLOW_TEARING, &tearing, sizeof(tearing));
  DXGI_SWAP_CHAIN_DESC1 desc{};
  desc.Width = packet->width; desc.Height = packet->height; desc.Format = format;
  desc.SampleDesc.Count = 1; desc.BufferUsage = DXGI_USAGE_RENDER_TARGET_OUTPUT;
  desc.BufferCount = 2; desc.SwapEffect = DXGI_SWAP_EFFECT_FLIP_DISCARD;
  desc.Scaling = DXGI_SCALING_STRETCH; desc.AlphaMode = DXGI_ALPHA_MODE_IGNORE;
  desc.Flags = tearing ? DXGI_SWAP_CHAIN_FLAG_ALLOW_TEARING : 0;
  ComPtr<IDXGISwapChain1> initial_swapchain;
  Check(factory->CreateSwapChainForHwnd(queue.Get(), window.value, &desc, nullptr, nullptr, &initial_swapchain), Stage::swapchain);
  ComPtr<IDXGISwapChain3> swapchain;
  Check(initial_swapchain.As(&swapchain), Stage::swapchain);
  factory->MakeWindowAssociation(window.value, DXGI_MWA_NO_ALT_ENTER);
  UINT support = 0;
  Check(swapchain->CheckColorSpaceSupport(color_space, &support), Stage::swapchain);
  if (!(support & DXGI_SWAP_CHAIN_COLOR_SPACE_SUPPORT_FLAG_PRESENT)) throw Failure{Stage::swapchain, ERROR_NOT_SUPPORTED};
  Check(swapchain->SetColorSpace1(color_space), Stage::swapchain);
  std::array<ComPtr<ID3D12Resource>, 2> backbuffers;
  for (UINT i = 0; i < backbuffers.size(); ++i) Check(swapchain->GetBuffer(i, IID_PPV_ARGS(&backbuffers[i])), Stage::swapchain);
  ComPtr<ID3D12CommandAllocator> allocator;
  ComPtr<ID3D12GraphicsCommandList> commands;
  Check(device->CreateCommandAllocator(D3D12_COMMAND_LIST_TYPE_DIRECT, IID_PPV_ARGS(&allocator)), Stage::device);
  Check(device->CreateCommandList(0, D3D12_COMMAND_LIST_TYPE_DIRECT, allocator.Get(), nullptr, IID_PPV_ARGS(&commands)), Stage::device);
  Check(commands->Close(), Stage::device);

  ComPtr<ID3D12Resource> readback;
  D3D12_PLACED_SUBRESOURCE_FOOTPRINT footprint{};
  UINT64 readback_bytes = 0;
  if (packet->validation) {
    device->GetCopyableFootprints(&resource, 0, 1, 0, &footprint, nullptr, nullptr, &readback_bytes);
    D3D12_RESOURCE_DESC buffer{}; buffer.Dimension = D3D12_RESOURCE_DIMENSION_BUFFER;
    buffer.Width = readback_bytes; buffer.Height = buffer.DepthOrArraySize = buffer.MipLevels = 1;
    buffer.SampleDesc.Count = 1; buffer.Layout = D3D12_TEXTURE_LAYOUT_ROW_MAJOR;
    D3D12_HEAP_PROPERTIES cpu_heap{}; cpu_heap.Type = D3D12_HEAP_TYPE_READBACK;
    Check(device->CreateCommittedResource(&cpu_heap, D3D12_HEAP_FLAG_NONE, &buffer, D3D12_RESOURCE_STATE_COPY_DEST,
                                         nullptr, IID_PPV_ARGS(&readback)), Stage::copy);
  }
  *log << "DX12 output ready: " << packet->width << 'x' << packet->height << " format=" << packet->format
       << " colorSpace=" << packet->color_space << " FG requested=" << packet->generation_requested << std::endl;
  packet->output_window = uintptr_t(window.value);
  streamline.ConfigurePacing(packet);
  packet->state = State::ready;
  MemoryBarrier(); SetEvent(reply);
  uint64_t last_frame = 0;
  RECT output_rect{0, 0, LONG(packet->width), LONG(packet->height)};
  uint64_t last_input = 0, input_generation = 0;
  uint32_t last_input_flags = 0;
  std::array<acbrotherhood::frame_generation::ImportedImage, 4> images;
  // Shutdown while the tagged resources, swapchain and device remain alive.
  struct Shutdown {
    acbrotherhood::frame_generation::Streamline* value;
    ~Shutdown() { value->Shutdown(); }
  } shutdown{&streamline};
  // Destroy AA and release its Streamline viewport before shared runtime shutdown.
  std::unique_ptr<acbrotherhood::dlaa::Dlaa> dlaa;
  auto previous_status = acbrotherhood::frame_generation::Status::off;
  uint32_t previous_configured = 0;
  for (;;) {
    const HANDLE waits[] = {parent, request};
    const DWORD wait = MsgWaitForMultipleObjects(2, waits, FALSE, INFINITE, QS_ALLINPUT);
    if (wait == WAIT_OBJECT_0) break;
    if (wait == WAIT_OBJECT_0 + 2) {
      MSG message;
      while (PeekMessageW(&message, nullptr, 0, 0, PM_REMOVE)) { TranslateMessage(&message); DispatchMessageW(&message); }
      continue;
    }
    if (wait != WAIT_OBJECT_0 + 1) throw Failure{Stage::protocol, GetLastError()};
    MemoryBarrier();
    if (packet->command == Command::stop) break;
    if (packet->command == Command::dlaa_evaluate || packet->command == Command::dlaa_release) {
      auto& aa = packet->dlaa;
      try {
        if (packet->command == Command::dlaa_release) {
          if (dlaa && dlaa->generation == aa.generation) dlaa.reset();
          aa.state = acbrotherhood::dlaa::WorkerState::complete;
        } else {
          if (packet->frame != last_frame + 1 || aa.adapter_low != packet->adapter_low
              || aa.adapter_high != packet->adapter_high || aa.width != packet->width || aa.height != packet->height)
            throw acbrotherhood::dlaa::Failure{acbrotherhood::dlaa::Stage::protocol, ERROR_INVALID_DATA};
          if (dlaa && (dlaa->generation != aa.generation || dlaa->preset != aa.render_preset)) dlaa.reset();
          if (!dlaa) {
            dlaa = std::make_unique<acbrotherhood::dlaa::Dlaa>();
            dlaa->Start(&aa, device.Get(), queue.Get(), bridge5.Get(), context4.Get(), parent, &streamline, packet->validation != 0);
            *log << "Unified DLAA ready " << aa.width << 'x' << aa.height << " preset=" << aa.render_preset
                 << " device=" << device.Get() << " queue=" << queue.Get() << std::endl;
          }
          streamline.Begin(uint32_t(packet->frame), false); streamline.RenderBegin();
          dlaa->Evaluate(&aa);
        }
      } catch (const acbrotherhood::dlaa::Failure& failure) {
        dlaa.reset();
        aa.state = acbrotherhood::dlaa::WorkerState::failed; aa.stage = failure.stage; aa.error = failure.code;
        *log << "DLAA failed stage=" << uint32_t(failure.stage) << " error=" << failure.code << std::endl;
        // If the device was lost the presenter must fall back too.
        Check(device->GetDeviceRemovedReason(), Stage::device);
      }
      packet->state = State::complete;
      MemoryBarrier(); SetEvent(reply);
      continue;
    }
    const uint64_t frame = packet->frame;
    if (frame != last_frame + 1 || packet->sync_interval > 4 || packet->generation_requested > 5
        || packet->pacing.reflex_mode > 2 || packet->pacing.render_fps > 1000)
      throw Failure{Stage::protocol, ERROR_INVALID_DATA};
    if (packet->command == Command::begin_frame || packet->command == Command::render_begin) {
      if (packet->command == Command::begin_frame) {
        streamline.ConfigurePacing(packet);
        streamline.Begin(uint32_t(frame), true);
      }
      else streamline.RenderBegin();
      packet->state = State::complete;
      MemoryBarrier(); SetEvent(reply);
      continue;
    }
    if (packet->command != Command::present) throw Failure{Stage::protocol, ERROR_INVALID_DATA};
    RECT client{};
    if (!IsWindow(window.value) || !GetClientRect(game_window, &client)) throw Failure{Stage::window, ERROR_INVALID_WINDOW_HANDLE};
    if (client.right != output_rect.right || client.bottom != output_rect.bottom) {
      streamline.Pause();
      packet->pause_flags |= acbrotherhood::frame_generation::window_resizing;
      if (!SetWindowPos(window.value, nullptr, 0, 0, client.right, client.bottom,
                        SWP_NOACTIVATE | SWP_NOZORDER | SWP_NOMOVE | SWP_NOOWNERZORDER))
        throw Failure{Stage::window, GetLastError()};
      output_rect = client;
    }
    if (IsIconic(game_window) || GetAncestor(GetForegroundWindow(), GA_ROOT) != GetAncestor(game_window, GA_ROOT))
      packet->pause_flags |= acbrotherhood::frame_generation::window_inactive;
    Check(context4->Wait(source_fence.Get(), frame), Stage::sharing);
    Check(context4->Wait(fence11.Get(), last_frame * 4), Stage::sharing);
    context4->CopyResource(input11.Get(), source.Get());
    packet->accepted_inputs = 0;
    std::fill(std::begin(packet->input_checksums), std::end(packet->input_checksums), 0);
    const auto& auxiliary = packet->inputs;
    // Invalid/missing frame inputs disable their use, never the base image.
    // A handle may be recycled after Reset, so generation is part of identity.
    if ((auxiliary.flags & acbrotherhood::frame_generation::motion_depth) && auxiliary.id > last_input
        && auxiliary.generation && auxiliary.width == packet->width && auxiliary.height == packet->height
        && auxiliary.window == packet->window && !(auxiliary.flags & ~15u)) {
      try {
        if (input_generation != auxiliary.generation) { images = {}; input_generation = auxiliary.generation; }
        unsigned count = 2;
        if ((auxiliary.flags & 6u) == 6u && auxiliary.hudless_format == packet->format) count = (auxiliary.flags & acbrotherhood::frame_generation::ui_alpha) ? 4 : 3;
        for (unsigned i = 0; i < count; ++i) {
          if (images[i].handle != auxiliary.textures[i]) {
            images[i] = {};
            images[i].Open(bridge5.Get(), device.Get(), auxiliary.textures[i], packet->width, packet->height,
                i == 0 ? DXGI_FORMAT_R16G16B16A16_FLOAT : (i == 1 || i == 3) ? DXGI_FORMAT_R32_FLOAT : format, packet->validation != 0);
          }
        }
        for (unsigned i = 0; i < count; ++i) context4->CopyResource(images[i].bridge.Get(), images[i].source.Get());
        packet->accepted_inputs = count == 4 ? 15u : count == 3 ? 7u : 1u;
        last_input = auxiliary.id;
      } catch (const Failure& failure) {
        images = {}; input_generation = 0;
        *log << "FG input import rejected: stage=" << uint32_t(failure.stage) << " error=" << failure.code << std::endl;
      }
    }
    if (packet->accepted_inputs != last_input_flags) {
      *log << "FG input capture flags=" << packet->accepted_inputs << " id=" << auxiliary.id
           << " reset=" << auxiliary.reset << std::endl;
      last_input_flags = packet->accepted_inputs;
    }
    Check(context4->Signal(fence11.Get(), frame * 4 - 3), Stage::sharing);
    context4->Flush();
    Check(queue->Wait(fence.Get(), frame * 4 - 3), Stage::sharing);
    Check(allocator->Reset(), Stage::copy);
    Check(commands->Reset(allocator.Get(), nullptr), Stage::copy);
    for (unsigned i = 0; i < ((packet->accepted_inputs & 8) ? 4u : (packet->accepted_inputs & 2) ? 3u : packet->accepted_inputs ? 2u : 0u); ++i)
      images[i].Readback(commands.Get());
    ID3D12Resource* backbuffer = backbuffers[swapchain->GetCurrentBackBufferIndex()].Get();
    D3D12_RESOURCE_BARRIER barriers[2]{};
    for (auto& barrier : barriers) { barrier.Type = D3D12_RESOURCE_BARRIER_TYPE_TRANSITION; barrier.Transition.Subresource = D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES; }
    barriers[0].Transition = {input.Get(), D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES, D3D12_RESOURCE_STATE_COMMON, D3D12_RESOURCE_STATE_COPY_SOURCE};
    barriers[1].Transition = {backbuffer, D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES, D3D12_RESOURCE_STATE_PRESENT, D3D12_RESOURCE_STATE_COPY_DEST};
    commands->ResourceBarrier(2, barriers);
    commands->CopyResource(backbuffer, input.Get());
    if (readback) {
      D3D12_RESOURCE_BARRIER inspect = barriers[1];
      inspect.Transition.StateBefore = D3D12_RESOURCE_STATE_COPY_DEST;
      inspect.Transition.StateAfter = D3D12_RESOURCE_STATE_COPY_SOURCE;
      commands->ResourceBarrier(1, &inspect);
      D3D12_TEXTURE_COPY_LOCATION from{}, to{};
      from.pResource = backbuffer; from.Type = D3D12_TEXTURE_COPY_TYPE_SUBRESOURCE_INDEX;
      to.pResource = readback.Get(); to.Type = D3D12_TEXTURE_COPY_TYPE_PLACED_FOOTPRINT; to.PlacedFootprint = footprint;
      commands->CopyTextureRegion(&to, 0, 0, 0, &from, nullptr);
      std::swap(inspect.Transition.StateBefore, inspect.Transition.StateAfter);
      commands->ResourceBarrier(1, &inspect);
    }
    for (auto& barrier : barriers) std::swap(barrier.Transition.StateBefore, barrier.Transition.StateAfter);
    commands->ResourceBarrier(2, barriers);
    Check(commands->Close(), Stage::copy);
    ID3D12CommandList* lists[] = {commands.Get()};
    queue->ExecuteCommandLists(1, lists);
    Check(queue->Signal(fence.Get(), frame * 4 - 2), Stage::gpu_wait);
    // Keep the canvas hidden until its first complete image is resident. At
    // startup the parent may still be transitioning out of its launch window.
    // Later frames retain the normal GPU-fence/Present acknowledgement path.
    if (!last_frame) {
      Check(fence->SetEventOnCompletion(frame * 4 - 2, complete.value), Stage::gpu_wait);
      const HANDLE first_frame[] = {parent, complete.value};
      const DWORD ready = WaitForMultipleObjects(2, first_frame, FALSE, 2000);
      if (ready == WAIT_OBJECT_0) break;
      if (ready != WAIT_OBJECT_0 + 1) throw Failure{Stage::gpu_wait, WAIT_TIMEOUT};
      if (fence->GetCompletedValue() == UINT64_MAX) throw Failure{Stage::gpu_wait, uint32_t(device->GetDeviceRemovedReason())};
      ShowWindow(window.value, SW_SHOWNA);
    }
    streamline.ConfigurePacing(packet);
    const UINT flags = (packet->present_flags & DXGI_PRESENT_RESTART)
        | (tearing && !packet->pacing_state.sync_interval ? packet->present_flags & DXGI_PRESENT_ALLOW_TEARING : 0);
    streamline.Prepare(packet, images);
    overlay_input.Update(game_window);
    const HRESULT present = swapchain->Present(packet->pacing_state.sync_interval, flags);
    Check(present, Stage::present);
    streamline.AfterPresent(packet, queue.Get());
    if (present == DXGI_STATUS_OCCLUDED) packet->generated_present_count = 0;
    // DX11 will overwrite the inputs on a different queue. A pre-Present copy
    // fence is not enough: include Streamline's input-consumption fence before
    // acknowledging this frame and permitting the next producer write.
    Check(queue->Signal(fence.Get(), frame * 4), Stage::gpu_wait);
    Check(fence->SetEventOnCompletion(frame * 4, complete.value), Stage::gpu_wait);
    const HANDLE completion[] = {parent, complete.value};
    const DWORD finished = WaitForMultipleObjects(2, completion, FALSE, 2000);
    if (finished == WAIT_OBJECT_0) break;
    if (finished != WAIT_OBJECT_0 + 1) throw Failure{Stage::gpu_wait, WAIT_TIMEOUT};
    if (fence->GetCompletedValue() == UINT64_MAX) throw Failure{Stage::gpu_wait, uint32_t(device->GetDeviceRemovedReason())};
    if (packet->generation_status != previous_status || packet->generation_configured != previous_configured) {
      *log << "DLSS-G status=" << uint32_t(packet->generation_status) << " error=" << packet->generation_error
           << " presented=" << packet->generated_present_count << " frame=" << frame
           << " requested=" << packet->generation_requested << " configured=" << packet->generation_configured
           << " maximum=" << packet->generation_max << std::endl;
      previous_status = packet->generation_status;
      previous_configured = packet->generation_configured;
    }
    for (unsigned i = 0; i < ((packet->accepted_inputs & 8) ? 4u : (packet->accepted_inputs & 2) ? 3u : packet->accepted_inputs ? 2u : 0u); ++i)
      packet->input_checksums[i] = images[i].Checksum();
    if (readback) {
      void* mapped = nullptr;
      D3D12_RANGE range{0, SIZE_T(readback_bytes)};
      Check(readback->Map(0, &range, &mapped), Stage::copy);
      uint32_t checksum = 2166136261;
      for (UINT y = 0; y < packet->height; ++y) for (UINT x = 0; x < packet->width * (format == DXGI_FORMAT_R16G16B16A16_FLOAT ? 8 : 4); ++x)
        checksum = (checksum ^ static_cast<const unsigned char*>(mapped)[footprint.Offset + y * footprint.Footprint.RowPitch + x]) * 16777619;
      D3D12_RANGE written{0, 0}; readback->Unmap(0, &written); packet->checksum = checksum;
    }
    if (diagnostics) {
      for (UINT64 i = 0; i < diagnostics->GetNumStoredMessages(); ++i) {
        SIZE_T size = 0; diagnostics->GetMessage(i, nullptr, &size);
        std::vector<unsigned char> bytes(size);
        auto* message = reinterpret_cast<D3D12_MESSAGE*>(bytes.data());
        Check(diagnostics->GetMessage(i, message, &size), Stage::copy);
        if (message->Severity <= D3D12_MESSAGE_SEVERITY_ERROR) {
          *log << message->pDescription << std::endl;
          throw Failure{Stage::copy, ERROR_INVALID_DATA};
        }
      }
      diagnostics->ClearStoredMessages();
    }
    last_frame = frame;
    packet->completed = frame; packet->error = uint32_t(present); packet->state = State::complete;
    MemoryBarrier(); SetEvent(reply);
  }
  *log << "DX12 output stopped after " << last_frame << " frames" << std::endl;
}
}  // namespace

int wmain(int argc, wchar_t** argv) {
  if (argc != 6) return 1;
  std::array<Handle, 5> handles;
  for (unsigned i = 0; i < handles.size(); ++i) {
    wchar_t* end = nullptr;
    const auto value = std::wcstoull(argv[i + 1], &end, 10);
    if (!value || !end || *end) return 1;
    handles[i].value = reinterpret_cast<HANDLE>(value);
  }
  auto* packet = static_cast<Packet*>(MapViewOfFile(handles[0].value, FILE_MAP_ALL_ACCESS, 0, 0, sizeof(Packet)));
  if (!packet) return 1;
  std::ofstream log("renodx-dx12-present.log", std::ios::trunc);
  int result = 0;
  try { Run(packet, handles[1].value, handles[2].value, handles[3].value, handles[4].value, &log); }
  catch (const Failure& failure) {
    packet->stage = failure.stage; packet->error = failure.code; packet->state = State::failed;
    MemoryBarrier(); SetEvent(handles[2].value);
    log << "Failure stage=" << uint32_t(failure.stage) << " code=0x" << std::hex << failure.code << std::endl;
    result = 1;
  } catch (...) {
    packet->stage = Stage::protocol; packet->error = ERROR_UNHANDLED_EXCEPTION; packet->state = State::failed;
    MemoryBarrier(); SetEvent(handles[2].value); result = 1;
  }
  UnmapViewOfFile(packet);
  return result;
}
