/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#pragma once
#include <d3d11_4.h>
#include <dxgi1_6.h>
#include <wrl/client.h>
#include <memory>
#include <mutex>
#include "./helper_process.hpp"
#include "./presentation_protocol.hpp"
#include "./fg_encode.hpp"

namespace acbrotherhood::presentation {
using Microsoft::WRL::ComPtr;
using dlaa::Handle;
struct Client;
inline std::recursive_mutex mutex;
inline std::weak_ptr<Client> active_client;
struct Client {
  ComPtr<ID3D11Device> source_device;
  ComPtr<ID3D11Texture2D> shared_texture;
  ComPtr<ID3D11DeviceContext4> context;
  ComPtr<ID3D11Fence> source_fence;
  Handle mapping, request, reply, parent, fence_handle, job, process;
  Packet* packet = nullptr;
  uint64_t frame = 0;
  uint64_t source_sequence = 0, pending_source = 0;
  bool in_flight = false;
  bool dlaa_pending = false;
  bool failed = false;
  uint64_t begun_frame = 0;
  bool render_marked = false;
  uint32_t input_error = 0;
  frame_generation::Encoder encoder;
  ~Client() { Stop(); }
  void Stop() {
    if (process.value) {
      if (packet && !in_flight) {
        packet->command = Command::stop;
        MemoryBarrier(); SetEvent(request.value);
        const HANDLE waits[] = {process.value};
        helper::WaitForSignals(waits, 100);
      }
      job = Handle{};
      WaitForSingleObject(process.value, 1000);
      process = Handle{};
    }
    if (packet) { UnmapViewOfFile(packet); packet = nullptr; }
    mapping = Handle{}; request = Handle{}; reply = Handle{}; parent = Handle{}; fence_handle = Handle{};
    shared_texture.Reset(); source_fence.Reset(); context.Reset();
    source_device.Reset();
    encoder = {};
    in_flight = false;
    dlaa_pending = false;
    source_sequence = pending_source = 0;
  }
  void Wait(DWORD timeout, bool service_messages = true) {
    const HANDLE waits[] = {reply.value, process.value};
    const DWORD result = service_messages ? helper::WaitForSignals(waits, timeout)
                                         : WaitForMultipleObjects(2, waits, FALSE, timeout);
    if (result != WAIT_OBJECT_0) throw Failure{Stage::protocol, uint32_t(result == WAIT_TIMEOUT ? WAIT_TIMEOUT : ERROR_PROCESS_ABORTED)};
    MemoryBarrier();
    in_flight = false;
    if (packet->state == State::failed) throw Failure{packet->stage, packet->error};
  }
  DWORD PacingTimeout() const {
    // The driver may finish a sleep scheduled with the previous cap. Include
    // both intervals before transferring ownership, even when removing a cap.
    // Allow a simultaneous multiplier change to finish its old schedule too.
    return 2000 + std::max(CalculatePacing(packet->pacing, 5, 5, 0).interval_us,
        packet->pacing_state.interval_us) * 6 / 1000;
  }
  // Serialized with Present/Reflex on the same IPC channel and DX12 queue.
  // A DLAA feature failure leaves presentation alive; a transport failure does not.
  // Submit CPU preparation before DX9 finishes its input draw. The helper
  // queues a GPU wait and cannot read those textures until FinishDlaa signals.
  void BeginDlaa(const dlaa::Packet& inputs, bool release = false) {
    if (!packet || failed || in_flight) throw Failure{Stage::protocol, ERROR_INVALID_STATE};
    try {
      packet->dlaa = inputs;
      packet->command = release ? Command::dlaa_release : Command::dlaa_evaluate;
      packet->frame = frame + 1;
      packet->source_ready = pending_source = release ? 0 : ++source_sequence;
      dlaa_pending = true;
      in_flight = true;
      MemoryBarrier();
      if (!SetEvent(request.value)) throw Failure{Stage::protocol, GetLastError()};
    } catch (...) {
      failed = true;
      Stop();
      throw;
    }
  }
  // Caller must have completed the native DX9 input event query. Acknowledge
  // only after the helper finishes its final copy back into the DX9 texture.
  void FinishDlaa(dlaa::Packet* inputs) {
    if (!packet || failed || !in_flight || !dlaa_pending) throw Failure{Stage::protocol, ERROR_INVALID_STATE};
    try {
      if (pending_source) {
        Check(context->Signal(source_fence.Get(), pending_source), Stage::sharing);
        context->Flush();
      }
      // AA never changes HWNDs. Do not dispatch a reset into the active DX9 draw.
      Wait(10000, false);
      if (packet->state != State::complete) throw Failure{Stage::protocol, ERROR_INVALID_DATA};
      *inputs = packet->dlaa;
      dlaa_pending = false;
      pending_source = 0;
    } catch (...) {
      failed = true;
      Stop();
      throw;
    }
  }
  void Dlaa(dlaa::Packet* inputs, bool release = false) {
    BeginDlaa(*inputs, release);
    FinishDlaa(inputs);
  }
  void Start(ID3D11Device* device, const D3D11_TEXTURE2D_DESC& source, HWND window,
             DXGI_COLOR_SPACE_TYPE color_space, const std::filesystem::path& executable, bool validation = false,
             uint32_t generation = 0, const PacingSettings& pacing = {}) {
    source_device = device;
    if (!source.Width || !source.Height || uint64_t(source.Width) * source.Height > 8388608
        || source.SampleDesc.Count != 1 || source.ArraySize != 1 || source.MipLevels != 1)
      throw Failure{Stage::sharing, ERROR_NOT_SUPPORTED};
    SECURITY_ATTRIBUTES security{sizeof(security), nullptr, TRUE};
    mapping = Handle(CreateFileMappingW(INVALID_HANDLE_VALUE, &security, PAGE_READWRITE, 0, sizeof(Packet), nullptr));
    request = Handle(CreateEventW(&security, FALSE, FALSE, nullptr));
    reply = Handle(CreateEventW(&security, FALSE, FALSE, nullptr));
    if (!mapping.value || !request.value || !reply.value
        || !DuplicateHandle(GetCurrentProcess(), GetCurrentProcess(), GetCurrentProcess(), &parent.value,
                            SYNCHRONIZE | PROCESS_QUERY_LIMITED_INFORMATION, TRUE, 0))
      throw Failure{Stage::protocol, GetLastError()};
    packet = static_cast<Packet*>(MapViewOfFile(mapping.value, FILE_MAP_ALL_ACCESS, 0, 0, sizeof(Packet)));
    if (!packet) throw Failure{Stage::protocol, GetLastError()};
    new (packet) Packet{};
    packet->width = source.Width; packet->height = source.Height; packet->format = source.Format;
    packet->window = uintptr_t(window); packet->color_space = color_space; packet->validation = validation;
    packet->generation_requested = generation;
    packet->pacing = pacing;
    ComPtr<IDXGIDevice> dxgi_device;
    ComPtr<IDXGIAdapter> adapter;
    Check(device->QueryInterface(IID_PPV_ARGS(&dxgi_device)), Stage::adapter);
    Check(dxgi_device->GetAdapter(&adapter), Stage::adapter);
    DXGI_ADAPTER_DESC adapter_desc{};
    Check(adapter->GetDesc(&adapter_desc), Stage::adapter);
    packet->adapter_low = adapter_desc.AdapterLuid.LowPart; packet->adapter_high = adapter_desc.AdapterLuid.HighPart;
    D3D11_TEXTURE2D_DESC desc = source;
    desc.Usage = D3D11_USAGE_DEFAULT; desc.CPUAccessFlags = 0;
    desc.BindFlags = D3D11_BIND_SHADER_RESOURCE | D3D11_BIND_RENDER_TARGET;
    desc.MiscFlags = D3D11_RESOURCE_MISC_SHARED;
    Check(device->CreateTexture2D(&desc, nullptr, &shared_texture), Stage::sharing);
    ComPtr<IDXGIResource> dxgi_resource;
    Check(shared_texture.As(&dxgi_resource), Stage::sharing);
    HANDLE legacy = nullptr;  // A driver handle; never CloseHandle.
    Check(dxgi_resource->GetSharedHandle(&legacy), Stage::sharing);
    packet->source_texture = uintptr_t(legacy);
    ComPtr<ID3D11Device5> device5;
    Check(device->QueryInterface(IID_PPV_ARGS(&device5)), Stage::device);
    ComPtr<ID3D11DeviceContext> immediate;
    device->GetImmediateContext(&immediate);
    Check(immediate.As(&context), Stage::device);
    Check(device5->CreateFence(0, D3D11_FENCE_FLAG_SHARED, IID_PPV_ARGS(&source_fence)), Stage::sharing);
    Check(source_fence->CreateSharedHandle(&security, GENERIC_ALL, nullptr, &fence_handle.value), Stage::sharing);
    const HANDLE inherited[] = {mapping.value, request.value, reply.value, parent.value, fence_handle.value};
    const DWORD result = helper::Launch(executable, inherited, &job, &process);
    if (result) throw Failure{Stage::protocol, result};
    in_flight = true;
    Wait(10000);
    if (packet->state != State::ready) throw Failure{Stage::protocol, ERROR_INVALID_DATA};
  }
  // IPC occurs at real native frame boundaries, not as synthetic markers
  // around a completed frame. The game waits for Reflex before its next tick.
  bool Timing(Command command) {
    if (in_flight || !packet || !packet->pacing_state.available) return false;
    if (command == Command::begin_frame) {
      if (begun_frame == frame + 1) return false;
      begun_frame = frame + 1; render_marked = false;
    } else if (command == Command::render_begin) {
      if (begun_frame != frame + 1 || render_marked) return false;
      render_marked = true;
    } else return false;
    packet->frame = frame + 1; packet->command = command; in_flight = true;
    const DWORD timeout = PacingTimeout();
    MemoryBarrier(); SetEvent(request.value);
    Wait(timeout);
    if (packet->state != State::complete) throw Failure{Stage::protocol, ERROR_INVALID_DATA};
    return true;
  }
  HRESULT Present(ID3D11Texture2D* source, UINT sync_interval, UINT flags, const frame_generation::Inputs* inputs = nullptr,
                  uint32_t pause_flags = 0) {
    if (!packet || failed || in_flight) throw Failure{Stage::protocol, ERROR_INVALID_STATE};
    if (sync_interval > 4 || (flags & ~(DXGI_PRESENT_ALLOW_TEARING | DXGI_PRESENT_RESTART)))
      throw Failure{Stage::present, ERROR_NOT_SUPPORTED};
    packet->frame = ++frame; packet->sync_interval = sync_interval; packet->present_flags = flags;
    packet->inputs = inputs ? *inputs : frame_generation::Inputs{};
    packet->pause_flags = pause_flags;
    packet->accepted_inputs = 0;
    input_error = 0;
    if ((packet->inputs.flags & (frame_generation::hudless | frame_generation::hdr_encoded)) == frame_generation::hudless) {
      bool encoded = false;
      try {
        D3D11_TEXTURE2D_DESC desc{}; source->GetDesc(&desc);
        encoded = encoder.Encode(source_device.Get(), desc, &packet->inputs);
      } catch (const Failure& failure) { input_error = failure.code; encoder = {}; }
        catch (...) { input_error = E_FAIL; encoder = {}; }
      if (!encoded) {
        if (!input_error) input_error = ERROR_NOT_SUPPORTED;
        packet->inputs.flags &= ~(frame_generation::hudless | frame_generation::hdr_encoded);
        packet->inputs.textures[2] = 0;
      }
    }
    context->CopyResource(shared_texture.Get(), source);
    packet->source_ready = ++source_sequence;
    Check(context->Signal(source_fence.Get(), packet->source_ready), Stage::sharing);
    context->Flush();  // Publish the source copy and fence; no CPU readback/wait.
    packet->command = Command::present;
    in_flight = true;
    const DWORD timeout = PacingTimeout();
    MemoryBarrier(); SetEvent(request.value);
    Wait(timeout);
    if (packet->state != State::complete || packet->completed != frame)
      throw Failure{Stage::protocol, ERROR_INVALID_DATA};
    return HRESULT(packet->error);  // Includes DXGI_STATUS_OCCLUDED.
  }
};
}  // namespace acbrotherhood::presentation
