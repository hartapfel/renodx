// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
// Real addon cloud rendering and DXR-state restoration in the isolated host.
#pragma once
#include <map>
inline api::command_list* cloud_host_command = nullptr;
inline api::device* cloud_host_device = nullptr;
inline std::map<uint64_t, uint32_t> cloud_hdr_roots;
inline std::map<uint64_t, uint32_t> cloud_lighting_roots;
inline std::map<uint64_t, uint32_t> cloud_shadow_roots;
inline void CloudInspectCommand(api::command_list* command) { cloud_host_command = command; }
inline void CloudInspectDevice(api::device* device) { cloud_host_device = device; }
inline void CloudInspectLayout(api::device*, uint32_t count, const api::pipeline_layout_param* parameters, api::pipeline_layout layout) {
  const hartapfelfx::fog::BindingLayout decoded(count, parameters);
  for (uint32_t index = 0; index < decoded.parameters.size(); ++index)
    for (const auto& range : decoded.parameters[index].ranges)
      if (range.dx_register_space == 50 && range.dx_register_index == 13 && range.type == api::descriptor_type::constant_buffer) cloud_hdr_roots[layout.handle] = index;
      else if (range.dx_register_space == 73 && range.dx_register_index == 0 && range.type == api::descriptor_type::constant_buffer)
        cloud_lighting_roots[layout.handle] = index;
      else if (range.dx_register_space == 72 && range.dx_register_index == 0 && range.type == api::descriptor_type::buffer_shader_resource_view)
        cloud_shadow_roots[layout.handle] = index;
}
inline void CloudRuntime(ID3D12Device* device, const std::filesystem::path& originals, const std::filesystem::path& embed,
                         const std::filesystem::path& libraries, const std::filesystem::path& probes, IDxcUtils* reflection) {
  auto common = Root(device, true, 4, false, 1u << 9, true);
  auto pair = [&](const char* vertex_name, const char* pixel_name, std::span<const DXGI_FORMAT> formats) {
    auto vertex = Read(originals / vertex_name);
    const auto pixel = pixel_name ? Read(originals / pixel_name) : std::vector<char>{};
    ComPtr<ID3D12ShaderReflection> shader;
    const DxcBuffer buffer{vertex.data(), vertex.size(), 0};
    Check(reflection->CreateReflection(&buffer, IID_PPV_ARGS(&shader)));
    D3D12_SHADER_DESC info{}; Check(shader->GetDesc(&info));
    const DXGI_FORMAT types[3][4] = {
        {DXGI_FORMAT_R32_UINT, DXGI_FORMAT_R32G32_UINT, DXGI_FORMAT_R32G32B32_UINT, DXGI_FORMAT_R32G32B32A32_UINT},
        {DXGI_FORMAT_R32_SINT, DXGI_FORMAT_R32G32_SINT, DXGI_FORMAT_R32G32B32_SINT, DXGI_FORMAT_R32G32B32A32_SINT},
        {DXGI_FORMAT_R32_FLOAT, DXGI_FORMAT_R32G32_FLOAT, DXGI_FORMAT_R32G32B32_FLOAT, DXGI_FORMAT_R32G32B32A32_FLOAT}};
    std::vector<D3D12_INPUT_ELEMENT_DESC> inputs;
    for (uint32_t index = 0; index < info.InputParameters; ++index) {
      D3D12_SIGNATURE_PARAMETER_DESC input{}; Check(shader->GetInputParameterDesc(index, &input));
      if (input.SystemValueType != D3D_NAME_UNDEFINED) continue;
      inputs.push_back({input.SemanticName, input.SemanticIndex, types[input.ComponentType - 1][std::popcount(uint32_t(input.Mask)) - 1], 0, D3D12_APPEND_ALIGNED_ELEMENT, D3D12_INPUT_CLASSIFICATION_PER_VERTEX_DATA, 0});
    }
    D3D12_GRAPHICS_PIPELINE_STATE_DESC desc{};
    desc.pRootSignature = common.Get(); desc.VS = {vertex.data(), vertex.size()}; desc.PS = {pixel.data(), pixel.size()};
    desc.InputLayout = {inputs.data(), uint32_t(inputs.size())};
    desc.RasterizerState.FillMode = D3D12_FILL_MODE_SOLID; desc.RasterizerState.CullMode = D3D12_CULL_MODE_NONE;
    desc.RasterizerState.DepthClipEnable = TRUE; desc.SampleMask = UINT_MAX; desc.SampleDesc.Count = 1;
    desc.PrimitiveTopologyType = D3D12_PRIMITIVE_TOPOLOGY_TYPE_TRIANGLE;
    desc.NumRenderTargets = uint32_t(formats.size()); std::copy(formats.begin(), formats.end(), desc.RTVFormats);
    for (auto& blend : desc.BlendState.RenderTarget) {
      blend.SrcBlend = blend.SrcBlendAlpha = D3D12_BLEND_ONE; blend.DestBlend = blend.DestBlendAlpha = D3D12_BLEND_ZERO;
      blend.BlendOp = blend.BlendOpAlpha = D3D12_BLEND_OP_ADD; blend.LogicOp = D3D12_LOGIC_OP_NOOP; blend.RenderTargetWriteMask = 15;
    }
    desc.DepthStencilState.DepthFunc = D3D12_COMPARISON_FUNC_ALWAYS;
    desc.DepthStencilState.FrontFace = {D3D12_STENCIL_OP_KEEP, D3D12_STENCIL_OP_KEEP, D3D12_STENCIL_OP_KEEP, D3D12_COMPARISON_FUNC_ALWAYS};
    desc.DepthStencilState.BackFace = desc.DepthStencilState.FrontFace;
    ComPtr<ID3D12PipelineState> result;
    std::cout << "Cloud native pair " << vertex_name << " / " << (pixel_name ? pixel_name : "depth-only") << " inputs=" << inputs.size() << std::endl;
    Check(device->CreateGraphicsPipelineState(&desc, IID_PPV_ARGS(&result)));
    return result;
  };
  const DXGI_FORMAT gbuffer_formats[4] = {DXGI_FORMAT_R8G8B8A8_UNORM, DXGI_FORMAT_R8G8B8A8_UNORM, DXGI_FORMAT_R8G8B8A8_UNORM, DXGI_FORMAT_R16G16B16A16_FLOAT};
  const DXGI_FORMAT scene_format[] = {DXGI_FORMAT_R32G32B32A32_FLOAT};
  auto gbuffer = pair("0x261F2A8F.vs_6_3.cso", "0x30DE6E02.ps_6_6.cso", gbuffer_formats);
  auto sun = pair("0x0C1350D8.vs_6_3.cso", "0x4A7A44D6.ps_6_6.cso", scene_format);
  auto deferred_sun = pair("0x0C1350D8.vs_6_3.cso", "0x806C62A8.ps_6_6.cso", scene_format);
  auto sky = pair("0xCCD2CA86.vs_6_3.cso", "0x449D3390.ps_6_6.cso", scene_format);
  auto moon_disc = pair("0x14AEBBFB.vs_6_3.cso", "0xE446F231.ps_6_6.cso", scene_format);
  auto sun_disc = pair("0xE1C4426E.vs_6_3.cso", "0xE46451D5.ps_6_6.cso", scene_format);
  auto cloud_card = pair("0xF20F0978.vs_6_3.cso", "0xBF0CA052.ps_6_6.cso", scene_format);
  auto animated_card=pair("0xB5373B9F.vs_6_3.cso","0x683213A3.ps_6_6.cso",scene_format);
  ComPtr<ID3D12PipelineState> local_mist;
  if(std::filesystem::exists(originals/"0x6350BBBF.vs_6_3.cso"))
    local_mist=pair("0x6350BBBF.vs_6_3.cso","0x093DCC92.ps_6_6.cso",scene_format);
  const bool alternate_sky = std::filesystem::exists(originals / "0x979EED1B.vs_6_3.cso")
      && std::filesystem::exists(originals / "0xA35EA14D.ps_6_6.cso");
  ComPtr<ID3D12PipelineState> sky_toussaint, sun_toussaint, card_toussaint, background_toussaint, material_storm;
  if (alternate_sky) {
    sky_toussaint = pair("0x979EED1B.vs_6_3.cso", "0x3B15DAAB.ps_6_6.cso", scene_format);
    sun_toussaint = pair("0x7A54F808.vs_6_3.cso", "0xA0A02407.ps_6_6.cso", scene_format);
    card_toussaint = pair("0x6AB84A91.vs_6_3.cso", "0xA35EA14D.ps_6_6.cso", scene_format);
    background_toussaint = pair("0xB38E970F.vs_6_3.cso", "0x2AF34748.ps_6_6.cso", scene_format);
    material_storm = pair("0x62612355.vs_6_3.cso", "0x093DCC92.ps_6_6.cso", scene_format);
  }
  auto atlas_convert=pair("0xE561350A.vs_6_3.cso","0xF716B319.ps_6_6.cso",scene_format);
  auto vertex_shadow_a = pair("0x35E6FF87.vs_6_3.cso",nullptr,{});
  auto vertex_shadow_b = pair("0x52A112DE.vs_6_3.cso",nullptr,{});
  auto vertex = Read(embed / "0xF7F00001.cso"), pixel = Read(probes / "cloud-state.cso");
  D3D12_GRAPHICS_PIPELINE_STATE_DESC probe_desc{};
  probe_desc.pRootSignature = common.Get(); probe_desc.VS = {vertex.data(), vertex.size()}; probe_desc.PS = {pixel.data(), pixel.size()};
  probe_desc.RasterizerState.FillMode = D3D12_FILL_MODE_SOLID; probe_desc.RasterizerState.CullMode = D3D12_CULL_MODE_NONE; probe_desc.RasterizerState.DepthClipEnable = TRUE;
  probe_desc.SampleMask = UINT_MAX; probe_desc.SampleDesc.Count = 1; probe_desc.PrimitiveTopologyType = D3D12_PRIMITIVE_TOPOLOGY_TYPE_TRIANGLE;
  probe_desc.NumRenderTargets = 1; probe_desc.RTVFormats[0] = scene_format[0];
  for (auto& blend : probe_desc.BlendState.RenderTarget) { blend.SrcBlend = blend.SrcBlendAlpha = D3D12_BLEND_ONE; blend.DestBlend = blend.DestBlendAlpha = D3D12_BLEND_ZERO; blend.BlendOp = blend.BlendOpAlpha = D3D12_BLEND_OP_ADD; blend.LogicOp = D3D12_LOGIC_OP_NOOP; blend.RenderTargetWriteMask = 15; }
  probe_desc.DepthStencilState.DepthFunc = D3D12_COMPARISON_FUNC_ALWAYS;
  probe_desc.DepthStencilState.FrontFace = {D3D12_STENCIL_OP_KEEP, D3D12_STENCIL_OP_KEEP, D3D12_STENCIL_OP_KEEP, D3D12_COMPARISON_FUNC_ALWAYS}; probe_desc.DepthStencilState.BackFace = probe_desc.DepthStencilState.FrontFace;
  ComPtr<ID3D12PipelineState> graphics_probe; Check(device->CreateGraphicsPipelineState(&probe_desc, IID_PPV_ARGS(&graphics_probe)));
  constexpr uint32_t width = 320, height = 180;
  std::array<std::array<float, 4>, 352> frame{};
  frame[1] = {1,0,0,0}; frame[2] = {0,-.4472136f,.8944272f,0}; frame[3] = {0,.8944272f,.4472136f,0}; frame[4] = {0,0,0,1};
  frame[13] = {1,0,0,0}; frame[14] = {0,1,0,0}; frame[15] = {0,0,1.00004f,1}; frame[16] = {0,0,-.200008f,0};
  frame[17] = frame[1]; frame[18] = frame[2]; frame[19] = {0,0,0,-4.9998f}; frame[20] = {0,.8944272f,.4472136f,5};
  frame[22] = {-1,1,.2f,5000}; frame[23] = {width,height,1.f/width,1.f/height}; frame[66] = {5,0,0,0}; frame[68] = {0,1,0,0};
  for (uint32_t index : {195u,196u,197u,198u}) frame[index] = {.1f,.2f,.4f,0};
  frame[203] = {1,1,1,0}; frame[204] = {1,0,1,1}; frame[205] = {1,0,-1,-1}; frame[206] = {1,0,0,0};
  std::array<std::array<float, 4>, 3600> lighting{}; lighting[0] = {.1f,.4f,.91f,1}; lighting[1] = {30,20,10,0};
  std::array<std::array<float, 4>, 112> camera{}; camera[16] = lighting[0]; camera[17] = lighting[1];
  std::array<float, 64> clock{}; clock[0] = 100;
  std::array<uint8_t, 65536> empty{};
  auto zero = RuntimeBuffer(device, empty.size(), D3D12_HEAP_TYPE_UPLOAD, D3D12_RESOURCE_STATE_GENERIC_READ, empty.data());
  auto frame_buffer = RuntimeBuffer(device, sizeof(frame), D3D12_HEAP_TYPE_UPLOAD, D3D12_RESOURCE_STATE_GENERIC_READ, frame.data());
  auto light_buffer = RuntimeBuffer(device, sizeof(lighting), D3D12_HEAP_TYPE_UPLOAD, D3D12_RESOURCE_STATE_GENERIC_READ, lighting.data());
  auto camera_buffer = RuntimeBuffer(device, sizeof(camera), D3D12_HEAP_TYPE_UPLOAD, D3D12_RESOURCE_STATE_GENERIC_READ, camera.data());
  auto clock_buffer = RuntimeBuffer(device, sizeof(clock), D3D12_HEAP_TYPE_UPLOAD, D3D12_RESOURCE_STATE_GENERIC_READ, clock.data());
  const float sentinel[64] = {.125f,.25f,.5f,.75f};
  auto sentinel_buffer = RuntimeBuffer(device, sizeof(sentinel), D3D12_HEAP_TYPE_UPLOAD, D3D12_RESOURCE_STATE_GENERIC_READ, sentinel);
  ComPtr<ID3D12DescriptorHeap> heap, samplers, rtvs;
  const D3D12_DESCRIPTOR_HEAP_DESC heap_desc{D3D12_DESCRIPTOR_HEAP_TYPE_CBV_SRV_UAV, 176, D3D12_DESCRIPTOR_HEAP_FLAG_SHADER_VISIBLE};
  Check(device->CreateDescriptorHeap(&heap_desc, IID_PPV_ARGS(&heap)));
  const D3D12_DESCRIPTOR_HEAP_DESC sampler_desc{D3D12_DESCRIPTOR_HEAP_TYPE_SAMPLER, 16, D3D12_DESCRIPTOR_HEAP_FLAG_SHADER_VISIBLE};
  Check(device->CreateDescriptorHeap(&sampler_desc, IID_PPV_ARGS(&samplers)));
  D3D12_SAMPLER_DESC sampler{}; sampler.Filter = D3D12_FILTER_MIN_MAG_MIP_LINEAR; sampler.AddressU = sampler.AddressV = sampler.AddressW = D3D12_TEXTURE_ADDRESS_MODE_CLAMP; sampler.ComparisonFunc = D3D12_COMPARISON_FUNC_ALWAYS; sampler.MaxLOD = D3D12_FLOAT32_MAX;
  const uint32_t sampler_increment = device->GetDescriptorHandleIncrementSize(D3D12_DESCRIPTOR_HEAP_TYPE_SAMPLER);
  for (uint32_t index = 0; index < 16; ++index) device->CreateSampler(&sampler, {samplers->GetCPUDescriptorHandleForHeapStart().ptr + index * sampler_increment});
  const D3D12_DESCRIPTOR_HEAP_DESC rtv_desc{D3D12_DESCRIPTOR_HEAP_TYPE_RTV, 8}; Check(device->CreateDescriptorHeap(&rtv_desc, IID_PPV_ARGS(&rtvs)));
  const uint32_t increment = device->GetDescriptorHandleIncrementSize(D3D12_DESCRIPTOR_HEAP_TYPE_CBV_SRV_UAV), rtv_increment = device->GetDescriptorHandleIncrementSize(D3D12_DESCRIPTOR_HEAP_TYPE_RTV);
  auto cpu = [&](uint32_t slot) { return D3D12_CPU_DESCRIPTOR_HANDLE{heap->GetCPUDescriptorHandleForHeapStart().ptr + slot * increment}; };
  auto gpu = [&](uint32_t slot) { return D3D12_GPU_DESCRIPTOR_HANDLE{heap->GetGPUDescriptorHandleForHeapStart().ptr + slot * increment}; };
  auto target = [&](uint32_t slot) { return D3D12_CPU_DESCRIPTOR_HANDLE{rtvs->GetCPUDescriptorHandleForHeapStart().ptr + slot * rtv_increment}; };
  D3D12_SHADER_RESOURCE_VIEW_DESC null_srv{}; null_srv.Format = DXGI_FORMAT_R32_FLOAT; null_srv.ViewDimension = D3D12_SRV_DIMENSION_TEXTURE2D; null_srv.Shader4ComponentMapping = D3D12_DEFAULT_SHADER_4_COMPONENT_MAPPING; null_srv.Texture2D.MipLevels = 1;
  for (uint32_t index = 0; index < 128; ++index) device->CreateShaderResourceView(nullptr, &null_srv, cpu(index));
  D3D12_UNORDERED_ACCESS_VIEW_DESC null_uav{}; null_uav.Format = DXGI_FORMAT_R32_FLOAT; null_uav.ViewDimension = D3D12_UAV_DIMENSION_TEXTURE2D;
  for (uint32_t index = 128; index < 160; ++index) device->CreateUnorderedAccessView(nullptr, nullptr, &null_uav, cpu(index));
  const D3D12_HEAP_PROPERTIES default_heap{D3D12_HEAP_TYPE_DEFAULT};
  auto image = [&](DXGI_FORMAT format, uint16_t layers, D3D12_RESOURCE_FLAGS flags, D3D12_RESOURCE_STATES state, uint32_t w = width, uint32_t h = height) {
    D3D12_RESOURCE_DESC desc{}; desc.Dimension = D3D12_RESOURCE_DIMENSION_TEXTURE2D; desc.Width = w; desc.Height = h; desc.DepthOrArraySize = layers; desc.MipLevels = desc.SampleDesc.Count = 1; desc.Format = format; desc.Flags = flags;
    ComPtr<ID3D12Resource> result; Check(device->CreateCommittedResource(&default_heap, D3D12_HEAP_FLAG_NONE, &desc, state, nullptr, IID_PPV_ARGS(&result))); return result;
  };
  std::array<ComPtr<ID3D12Resource>, 6> targets;
  for (uint32_t index = 0; index < 6; ++index) {
    targets[index] = image(index < 4 ? gbuffer_formats[index] : scene_format[0], 1, D3D12_RESOURCE_FLAG_ALLOW_RENDER_TARGET, D3D12_RESOURCE_STATE_RENDER_TARGET);
    device->CreateRenderTargetView(targets[index].Get(), nullptr, target(index));
  }
  auto depth = image(DXGI_FORMAT_R32G8X24_TYPELESS, 1, D3D12_RESOURCE_FLAG_ALLOW_DEPTH_STENCIL, D3D12_RESOURCE_STATE_ALL_SHADER_RESOURCE);
  auto weather = image(DXGI_FORMAT_R32_FLOAT, 2, D3D12_RESOURCE_FLAG_ALLOW_UNORDERED_ACCESS, D3D12_RESOURCE_STATE_UNORDERED_ACCESS, 8, 8);
  auto texture = image(DXGI_FORMAT_R32G32B32A32_FLOAT, 1, D3D12_RESOURCE_FLAG_ALLOW_UNORDERED_ACCESS, D3D12_RESOURCE_STATE_UNORDERED_ACCESS, 1, 1);
  auto depth_view = null_srv; depth_view.Format = DXGI_FORMAT_R32_FLOAT_X8X24_TYPELESS; device->CreateShaderResourceView(depth.Get(), &depth_view, cpu(0));
  auto weather_view = null_srv; weather_view.ViewDimension = D3D12_SRV_DIMENSION_TEXTURE2DARRAY; weather_view.Texture2DArray = {0,1,0,2,0,0};
  device->CreateShaderResourceView(weather.Get(), &weather_view, cpu(14)); device->CreateShaderResourceView(weather.Get(), &weather_view, cpu(25));
  auto shadow_texture = image(DXGI_FORMAT_R16_TYPELESS, 4, D3D12_RESOURCE_FLAG_ALLOW_DEPTH_STENCIL, D3D12_RESOURCE_STATE_ALL_SHADER_RESOURCE, 1, 1);
  auto cascades = weather_view; cascades.Format = DXGI_FORMAT_R16_UNORM; cascades.Texture2DArray.ArraySize = 4; device->CreateShaderResourceView(shadow_texture.Get(), &cascades, cpu(8));
  auto texture_view = null_srv; texture_view.Format = DXGI_FORMAT_R32G32B32A32_FLOAT; device->CreateShaderResourceView(texture.Get(), &texture_view, cpu(9));
  auto weather_uav = null_uav; weather_uav.ViewDimension = D3D12_UAV_DIMENSION_TEXTURE2DARRAY; weather_uav.Texture2DArray.ArraySize = 2; device->CreateUnorderedAccessView(weather.Get(), nullptr, &weather_uav, cpu(128));
  auto texture_uav = null_uav; texture_uav.Format = DXGI_FORMAT_R32G32B32A32_FLOAT; device->CreateUnorderedAccessView(texture.Get(), nullptr, &texture_uav, cpu(129));
  ComPtr<ID3D12CommandQueue> queue; const D3D12_COMMAND_QUEUE_DESC queue_desc{}; Check(device->CreateCommandQueue(&queue_desc, IID_PPV_ARGS(&queue)));
  ComPtr<ID3D12CommandAllocator> allocator; Check(device->CreateCommandAllocator(D3D12_COMMAND_LIST_TYPE_DIRECT, IID_PPV_ARGS(&allocator)));
  ComPtr<ID3D12Device4> recording_device;
  Check(device->QueryInterface(IID_PPV_ARGS(&recording_device)));
  ComPtr<ID3D12GraphicsCommandList4> command;
  Check(recording_device->CreateCommandList1(0,D3D12_COMMAND_LIST_TYPE_DIRECT,D3D12_COMMAND_LIST_FLAG_NONE,IID_PPV_ARGS(&command)));
  Check(command->Reset(allocator.Get(),nullptr));
  ID3D12DescriptorHeap* native_heaps[] = {heap.Get(), samplers.Get()}; command->SetDescriptorHeaps(2, native_heaps);
  const float clear_weather[4] = {1,1,1,1}, clear_texture[4] = {.25f,.5f,.75f,1};
  command->ClearUnorderedAccessViewFloat(gpu(128), cpu(128), weather.Get(), clear_weather, 0, nullptr);
  command->ClearUnorderedAccessViewFloat(gpu(129), cpu(129), texture.Get(), clear_texture, 0, nullptr);
  D3D12_RESOURCE_BARRIER barriers[2]{};
  for (uint32_t index = 0; index < 2; ++index) { barriers[index].Type = D3D12_RESOURCE_BARRIER_TYPE_TRANSITION; barriers[index].Transition = {index ? texture.Get() : weather.Get(), D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES, D3D12_RESOURCE_STATE_UNORDERED_ACCESS, D3D12_RESOURCE_STATE_ALL_SHADER_RESOURCE}; }
  command->ResourceBarrier(2, barriers);
  command->SetGraphicsRootSignature(common.Get());
  for (uint32_t index = 0; index < 14; ++index) command->SetGraphicsRootConstantBufferView(index, zero->GetGPUVirtualAddress());
  command->SetGraphicsRootConstantBufferView(0, clock_buffer->GetGPUVirtualAddress()); command->SetGraphicsRootConstantBufferView(12, frame_buffer->GetGPUVirtualAddress()); command->SetGraphicsRootConstantBufferView(13, light_buffer->GetGPUVirtualAddress());
  command->SetGraphicsRootConstantBufferView(1,frame_buffer->GetGPUVirtualAddress());
  command->SetGraphicsRootDescriptorTable(14, gpu(0)); command->SetGraphicsRootDescriptorTable(15, gpu(128));
  const float graphics_words[4] = {.03125f,.0625f,.125f,.25f}; cloud_host_command->push_constants(api::shader_stage::all_graphics,{reinterpret_cast<uint64_t>(common.Get())},16,0,2,graphics_words); cloud_host_command->push_constants(api::shader_stage::all_graphics,{reinterpret_cast<uint64_t>(common.Get())},16,2,2,graphics_words+2);
  if (!cloud_hdr_roots.contains(reinterpret_cast<uint64_t>(common.Get()))) throw std::runtime_error("HDR test root unavailable");
  const api::buffer_range hdr_range{{reinterpret_cast<uint64_t>(sentinel_buffer.Get())},0,256};
  const api::descriptor_table_update hdr_update{{},0,0,1,api::descriptor_type::constant_buffer,&hdr_range};
  cloud_host_command->push_descriptors(api::shader_stage::all_graphics, {reinterpret_cast<uint64_t>(common.Get())}, cloud_hdr_roots.at(reinterpret_cast<uint64_t>(common.Get())), hdr_update);
  const D3D12_VIEWPORT viewport{0,0,width,height,0,1}; const D3D12_RECT scissor{0,0,width,height};
  command->RSSetViewports(1, &viewport); command->RSSetScissorRects(1, &scissor); command->IASetPrimitiveTopology(D3D_PRIMITIVE_TOPOLOGY_TRIANGLELIST);
  // PT uses different depth/material draws and can reach its first ray dispatch
  // without running the 30DE6E02 clock-capture draw.
  const auto first_target = target(0); command->OMSetRenderTargets(4, &first_target, TRUE, nullptr); command->SetPipelineState(gbuffer.Get());
  const auto scene_target = target(4); command->OMSetRenderTargets(1, &scene_target, FALSE, nullptr);
  const float background[4] = {.2f,.3f,.4f,.75f}; command->ClearRenderTargetView(scene_target, background, 0, nullptr);
  command->SetPipelineState(sun.Get()); command->DrawInstanced(0,1,0,0);
  command->SetPipelineState(deferred_sun.Get()); command->DrawInstanced(0,1,0,0);
  command->SetPipelineState(alternate_sky ? sky_toussaint.Get() : sky.Get()); command->DrawInstanced(0,1,0,0);
  command->SetPipelineState(moon_disc.Get()); command->DrawInstanced(0,1,0,0);
  command->SetPipelineState(alternate_sky ? sun_toussaint.Get() : sun_disc.Get()); command->DrawInstanced(0,1,0,0);
  const auto pre_card_desc = targets[4]->GetDesc();
  D3D12_PLACED_SUBRESOURCE_FOOTPRINT pre_card_footprint{};
  uint64_t pre_card_bytes = 0;
  device->GetCopyableFootprints(&pre_card_desc,0,1,0,&pre_card_footprint,nullptr,nullptr,&pre_card_bytes);
  auto pre_card = RuntimeBuffer(device,pre_card_bytes,D3D12_HEAP_TYPE_READBACK,D3D12_RESOURCE_STATE_COPY_DEST);
  D3D12_RESOURCE_BARRIER pre_card_barrier{};
  pre_card_barrier.Type = D3D12_RESOURCE_BARRIER_TYPE_TRANSITION;
  pre_card_barrier.Transition = {targets[4].Get(),D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES,
      D3D12_RESOURCE_STATE_RENDER_TARGET,D3D12_RESOURCE_STATE_COPY_SOURCE};
  command->ResourceBarrier(1,&pre_card_barrier);
  D3D12_TEXTURE_COPY_LOCATION pre_card_source{targets[4].Get(),D3D12_TEXTURE_COPY_TYPE_SUBRESOURCE_INDEX};
  D3D12_TEXTURE_COPY_LOCATION pre_card_destination{pre_card.Get(),D3D12_TEXTURE_COPY_TYPE_PLACED_FOOTPRINT};
  pre_card_destination.PlacedFootprint=pre_card_footprint;
  command->CopyTextureRegion(&pre_card_destination,0,0,0,&pre_card_source,nullptr);
  std::swap(pre_card_barrier.Transition.StateBefore,pre_card_barrier.Transition.StateAfter);
  command->ResourceBarrier(1,&pre_card_barrier);
  command->SetPipelineState(alternate_sky ? card_toussaint.Get() : animated_card.Get());command->DrawInstanced(0,1,0,0);
  if (alternate_sky) {
    command->SetPipelineState(background_toussaint.Get());command->DrawInstanced(0,1,0,0);
    command->SetPipelineState(material_storm.Get());command->DrawInstanced(0,1,0,0);
  }
  if(local_mist) {
    command->SetPipelineState(local_mist.Get());command->DrawInstanced(0,1,0,0);
  }
  auto native_atlas=image(scene_format[0],1,D3D12_RESOURCE_FLAG_ALLOW_RENDER_TARGET,
      D3D12_RESOURCE_STATE_RENDER_TARGET,768,512);
  auto atlas_projection=image(scene_format[0],1,D3D12_RESOURCE_FLAG_ALLOW_RENDER_TARGET,
      D3D12_RESOURCE_STATE_RENDER_TARGET,256,256);
  device->CreateRenderTargetView(native_atlas.Get(),nullptr,target(6));
  device->CreateRenderTargetView(atlas_projection.Get(),nullptr,target(7));
  const float clear_atlas[4]={.2f,.3f,.4f,1.f},filled_atlas[4]={.8f,.8f,.8f,1.f};
  const auto atlas_target=target(6),projection_target=target(7);
  command->OMSetRenderTargets(1,&atlas_target,FALSE,nullptr);
  command->ClearRenderTargetView(atlas_target,clear_atlas,0,nullptr);
  for(uint32_t face=0;face<6u;++face) {
    const D3D12_VIEWPORT face_view{float((face%3u)*256u),float((face/3u)*256u),256.f,256.f,0.f,1.f};
    const D3D12_RECT face_scissor{LONG(face_view.TopLeftX),LONG(face_view.TopLeftY),
        LONG(face_view.TopLeftX+256.f),LONG(face_view.TopLeftY+256.f)};
    command->RSSetViewports(1,&face_view);command->RSSetScissorRects(1,&face_scissor);
    command->SetPipelineState(alternate_sky ? sky_toussaint.Get() : sky.Get());command->DrawInstanced(0,1,0,0);
    command->SetPipelineState(alternate_sky ? card_toussaint.Get() : cloud_card.Get());command->DrawInstanced(0,1,0,0);
    if (alternate_sky) {
      command->SetPipelineState(background_toussaint.Get());command->DrawInstanced(0,1,0,0);
      command->SetPipelineState(material_storm.Get());command->DrawInstanced(0,1,0,0);
    }
  }
  command->ClearRenderTargetView(atlas_target,filled_atlas,0,nullptr);
  D3D12_RESOURCE_BARRIER atlas_barrier{};
  atlas_barrier.Type=D3D12_RESOURCE_BARRIER_TYPE_TRANSITION;
  atlas_barrier.Transition={native_atlas.Get(),D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES,
      D3D12_RESOURCE_STATE_RENDER_TARGET,D3D12_RESOURCE_STATE_ALL_SHADER_RESOURCE};
  command->ResourceBarrier(1,&atlas_barrier);
  auto atlas_view=texture_view;
  device->CreateShaderResourceView(native_atlas.Get(),&atlas_view,cpu(30));
  command->SetGraphicsRootDescriptorTable(14,gpu(30));
  const D3D12_VIEWPORT projection_view{0,0,256.f,256.f,0.f,1.f};
  const D3D12_RECT projection_scissor{0,0,256,256};
  command->OMSetRenderTargets(1,&projection_target,FALSE,nullptr);
  command->ClearRenderTargetView(projection_target,filled_atlas,0,nullptr);
  command->RSSetViewports(1,&projection_view);command->RSSetScissorRects(1,&projection_scissor);
  command->SetPipelineState(atlas_convert.Get());command->DrawInstanced(0,1,0,0);
  command->SetGraphicsRootDescriptorTable(14,gpu(0));
  command->RSSetViewports(1,&viewport);command->RSSetScissorRects(1,&scissor);
  D3D12_PLACED_SUBRESOURCE_FOOTPRINT atlas_footprint{};uint64_t atlas_bytes=0;
  const auto projection_desc=atlas_projection->GetDesc();
  device->GetCopyableFootprints(&projection_desc,0,1,0,&atlas_footprint,nullptr,nullptr,&atlas_bytes);
  auto atlas_readback=RuntimeBuffer(device,atlas_bytes,D3D12_HEAP_TYPE_READBACK,D3D12_RESOURCE_STATE_COPY_DEST);
  D3D12_RESOURCE_BARRIER projection_barrier{};
  projection_barrier.Type=D3D12_RESOURCE_BARRIER_TYPE_TRANSITION;
  projection_barrier.Transition={atlas_projection.Get(),D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES,
      D3D12_RESOURCE_STATE_RENDER_TARGET,D3D12_RESOURCE_STATE_COPY_SOURCE};
  command->ResourceBarrier(1,&projection_barrier);
  D3D12_TEXTURE_COPY_LOCATION atlas_source{atlas_projection.Get(),D3D12_TEXTURE_COPY_TYPE_SUBRESOURCE_INDEX};
  D3D12_TEXTURE_COPY_LOCATION atlas_destination{atlas_readback.Get(),D3D12_TEXTURE_COPY_TYPE_PLACED_FOOTPRINT};
  atlas_destination.PlacedFootprint=atlas_footprint;
  command->CopyTextureRegion(&atlas_destination,0,0,0,&atlas_source,nullptr);
  std::swap(projection_barrier.Transition.StateBefore,projection_barrier.Transition.StateAfter);
  command->ResourceBarrier(1,&projection_barrier);
  command->OMSetRenderTargets(0,nullptr,FALSE,nullptr);
  command->SetPipelineState(vertex_shadow_a.Get()); command->DrawInstanced(0,1,0,0);
  command->SetPipelineState(vertex_shadow_b.Get()); command->DrawInstanced(0,1,0,0);
  const auto probe_target = target(5); command->OMSetRenderTargets(1, &probe_target, FALSE, nullptr);
  command->SetPipelineState(graphics_probe.Get()); command->DrawInstanced(3,1,0,0);
  // Create the native libraries through the real detoured device. A local
  // root and association make lossy flattened-pipeline rebuilding detectable.
  ComPtr<ID3D12Device7> ray_device;
  Check(device->QueryInterface(IID_PPV_ARGS(&ray_device)));
  std::array<D3D12_ROOT_PARAMETER, 11> ray_parameters{};
  const D3D12_DESCRIPTOR_RANGE ray_camera_range{D3D12_DESCRIPTOR_RANGE_TYPE_CBV, 2, 0, 1, 0};
  ray_parameters[0].ParameterType = D3D12_ROOT_PARAMETER_TYPE_DESCRIPTOR_TABLE;
  ray_parameters[0].DescriptorTable = {1, &ray_camera_range};
  ray_parameters[1].ParameterType = ray_parameters[5].ParameterType = D3D12_ROOT_PARAMETER_TYPE_CBV;
  ray_parameters[1].Descriptor = {12,2}; ray_parameters[5].Descriptor = {0,96};
  D3D12_DESCRIPTOR_RANGE ray_ranges[5] = {
      {D3D12_DESCRIPTOR_RANGE_TYPE_SRV,128,0,1,0}, {D3D12_DESCRIPTOR_RANGE_TYPE_UAV,32,0,1,0},
      {D3D12_DESCRIPTOR_RANGE_TYPE_SAMPLER,16,0,1,0}, {D3D12_DESCRIPTOR_RANGE_TYPE_SRV,1,0,96,9},
      {D3D12_DESCRIPTOR_RANGE_TYPE_SAMPLER,1,0,96,0}};
  for (uint32_t index = 0; index < 5; ++index) {
    const uint32_t slot = index < 3 ? index + 2 : index + 4;
    ray_parameters[slot].ParameterType = D3D12_ROOT_PARAMETER_TYPE_DESCRIPTOR_TABLE;
    ray_parameters[slot].DescriptorTable = {1,&ray_ranges[index]};
  }
  ray_parameters[6].ParameterType = D3D12_ROOT_PARAMETER_TYPE_32BIT_CONSTANTS; ray_parameters[6].Constants = {0,97,4};
  ray_parameters[9].ParameterType = D3D12_ROOT_PARAMETER_TYPE_UAV; ray_parameters[9].Descriptor = {0,73};
  D3D12_DESCRIPTOR_RANGE hair_range{D3D12_DESCRIPTOR_RANGE_TYPE_SRV,64,0,2,0};
  ray_parameters[10].ParameterType = D3D12_ROOT_PARAMETER_TYPE_DESCRIPTOR_TABLE; ray_parameters[10].DescriptorTable = {1,&hair_range};
  D3D12_ROOT_SIGNATURE_DESC ray_desc{uint32_t(ray_parameters.size()),ray_parameters.data()};
  ComPtr<ID3DBlob> ray_blob, ray_errors;
  Check(D3D12SerializeRootSignature(&ray_desc,D3D_ROOT_SIGNATURE_VERSION_1,&ray_blob,&ray_errors));
  ComPtr<ID3D12RootSignature> ray_root;
  Check(device->CreateRootSignature(0,ray_blob->GetBufferPointer(),ray_blob->GetBufferSize(),IID_PPV_ARGS(&ray_root)));
  if (!cloud_shadow_roots.contains(reinterpret_cast<uint64_t>(ray_root.Get())))
    throw std::runtime_error("PT CameraCB descriptor range was not admitted for cloud shadows");
  D3D12_ROOT_PARAMETER local_parameter{}; local_parameter.ParameterType = D3D12_ROOT_PARAMETER_TYPE_32BIT_CONSTANTS; local_parameter.Constants = {0,95,4};
  const D3D12_ROOT_SIGNATURE_DESC local_desc{1,&local_parameter,0,nullptr,D3D12_ROOT_SIGNATURE_FLAG_LOCAL_ROOT_SIGNATURE};
  ComPtr<ID3DBlob> local_blob;
  Check(D3D12SerializeRootSignature(&local_desc,D3D_ROOT_SIGNATURE_VERSION_1,&local_blob,&ray_errors));
  ComPtr<ID3D12RootSignature> local_root;
  Check(device->CreateRootSignature(0,local_blob->GetBufferPointer(),local_blob->GetBufferSize(),IID_PPV_ARGS(&local_root)));
  const auto ray_probe = Read(probes / "cloud-ray.cso");
  const D3D12_DXIL_LIBRARY_DESC probe_library{{ray_probe.data(),ray_probe.size()},0,nullptr};
  const D3D12_GLOBAL_ROOT_SIGNATURE global_signature{ray_root.Get()};
  const D3D12_LOCAL_ROOT_SIGNATURE local_signature{local_root.Get()};
  const D3D12_RAYTRACING_SHADER_CONFIG shader_config{512,32};
  const D3D12_RAYTRACING_PIPELINE_CONFIG pipeline_config{2};
  const D3D12_STATE_OBJECT_CONFIG state_config{D3D12_STATE_OBJECT_FLAG_ALLOW_STATE_OBJECT_ADDITIONS};
  const wchar_t* probe_export = L"CloudProbeRGS";
  std::array<std::vector<char>,5> native_libraries;
  std::array<D3D12_DXIL_LIBRARY_DESC,5> native_descriptors{};
  std::array<D3D12_STATE_SUBOBJECT,12> objects{};
  const char* native_names[] = {"0x47BC87E1.library.cso","0x6D655BE6.library.cso","0xA3019513.library.cso","0xAA89D644.library.cso","0xF2FA912E.library.cso"};
  for (uint32_t index = 0; index < 5; ++index) {
    native_libraries[index] = Read(libraries / native_names[index]);
    native_descriptors[index] = {{native_libraries[index].data(),native_libraries[index].size()},0,nullptr};
    objects[index] = {D3D12_STATE_SUBOBJECT_TYPE_DXIL_LIBRARY,&native_descriptors[index]};
  }
  objects[5] = {D3D12_STATE_SUBOBJECT_TYPE_DXIL_LIBRARY,&probe_library};
  objects[6] = {D3D12_STATE_SUBOBJECT_TYPE_GLOBAL_ROOT_SIGNATURE,&global_signature};
  objects[7] = {D3D12_STATE_SUBOBJECT_TYPE_LOCAL_ROOT_SIGNATURE,&local_signature};
  const D3D12_SUBOBJECT_TO_EXPORTS_ASSOCIATION local_association{&objects[7],1,&probe_export};
  objects[8] = {D3D12_STATE_SUBOBJECT_TYPE_SUBOBJECT_TO_EXPORTS_ASSOCIATION,&local_association};
  objects[9] = {D3D12_STATE_SUBOBJECT_TYPE_RAYTRACING_SHADER_CONFIG,&shader_config};
  objects[10] = {D3D12_STATE_SUBOBJECT_TYPE_RAYTRACING_PIPELINE_CONFIG,&pipeline_config};
  objects[11] = {D3D12_STATE_SUBOBJECT_TYPE_STATE_OBJECT_CONFIG,&state_config};
  const D3D12_STATE_OBJECT_CONFIG collection_config{D3D12_STATE_OBJECT_FLAGS(
      D3D12_STATE_OBJECT_FLAG_ALLOW_LOCAL_DEPENDENCIES_ON_EXTERNAL_DEFINITIONS
      | D3D12_STATE_OBJECT_FLAG_ALLOW_EXTERNAL_DEPENDENCIES_ON_LOCAL_DEFINITIONS
      | D3D12_STATE_OBJECT_FLAG_ALLOW_STATE_OBJECT_ADDITIONS)};
  const D3D12_STATE_SUBOBJECT collection_objects[] = {
      {D3D12_STATE_SUBOBJECT_TYPE_DXIL_LIBRARY,&native_descriptors[3]},
      {D3D12_STATE_SUBOBJECT_TYPE_STATE_OBJECT_CONFIG,&collection_config}};
  const D3D12_STATE_OBJECT_DESC collection_desc{D3D12_STATE_OBJECT_TYPE_COLLECTION,2,collection_objects};
  ComPtr<ID3D12StateObject> collection;
  std::cout << "Creating rootless native cloud DXR collection" << std::endl;
  Check(ray_device->CreateStateObject(&collection_desc,IID_PPV_ARGS(&collection)));
  const D3D12_EXISTING_COLLECTION_DESC import_collection{collection.Get(),0,nullptr};
  objects[3] = {D3D12_STATE_SUBOBJECT_TYPE_EXISTING_COLLECTION,&import_collection};
  const D3D12_STATE_OBJECT_DESC state_desc{D3D12_STATE_OBJECT_TYPE_RAYTRACING_PIPELINE,uint32_t(objects.size()),objects.data()};
  ComPtr<ID3D12StateObject> state_object;
  std::cout << "Creating native cloud DXR state object" << std::endl;
  Check(ray_device->CreateStateObject(&state_desc,IID_PPV_ARGS(&state_object)));
  const D3D12_EXPORT_DESC added_export{L"AddedCloudProbeRGS",probe_export,D3D12_EXPORT_FLAG_NONE};
  const D3D12_DXIL_LIBRARY_DESC added_library{{ray_probe.data(),ray_probe.size()},1,&added_export};
  const wchar_t* added_name = added_export.Name;
  D3D12_STATE_SUBOBJECT added_objects[8] = {
      {D3D12_STATE_SUBOBJECT_TYPE_DXIL_LIBRARY,&added_library},
      {D3D12_STATE_SUBOBJECT_TYPE_LOCAL_ROOT_SIGNATURE,&local_signature}, {},
      {D3D12_STATE_SUBOBJECT_TYPE_RAYTRACING_SHADER_CONFIG,&shader_config}, {},
      {D3D12_STATE_SUBOBJECT_TYPE_GLOBAL_ROOT_SIGNATURE,&global_signature},
      {D3D12_STATE_SUBOBJECT_TYPE_STATE_OBJECT_CONFIG,&state_config},
      {D3D12_STATE_SUBOBJECT_TYPE_RAYTRACING_PIPELINE_CONFIG,&pipeline_config}};
  const D3D12_SUBOBJECT_TO_EXPORTS_ASSOCIATION added_association{&added_objects[1],1,&added_name};
  added_objects[2] = {D3D12_STATE_SUBOBJECT_TYPE_SUBOBJECT_TO_EXPORTS_ASSOCIATION,&added_association};
  const D3D12_SUBOBJECT_TO_EXPORTS_ASSOCIATION added_shader_association{&added_objects[3],1,&added_name};
  added_objects[4] = {D3D12_STATE_SUBOBJECT_TYPE_SUBOBJECT_TO_EXPORTS_ASSOCIATION,&added_shader_association};
  const D3D12_STATE_OBJECT_DESC added_desc{D3D12_STATE_OBJECT_TYPE_RAYTRACING_PIPELINE,8,added_objects};
  ComPtr<ID3D12StateObject> extended_state;
  std::cout << "Adding renamed probe to native DXR state object" << std::endl;
  Check(ray_device->AddToStateObject(&added_desc,state_object.Get(),IID_PPV_ARGS(&extended_state)));
  state_object = extended_state;
  ComPtr<ID3D12StateObjectProperties> properties;
  Check(state_object.As(&properties));
  const void* identifier = properties->GetShaderIdentifier(added_name);
  if (!identifier) throw std::runtime_error("Native DXR probe export lost");
  const uint32_t local_words[4] = {11,22,33,44}, ray_words[4] = {55,66,77,88};
  std::array<uint8_t,64> shader_record{};
  std::memcpy(shader_record.data(),identifier,32); std::memcpy(shader_record.data()+32,local_words,16);
  auto shader_table = RuntimeBuffer(device,64,D3D12_HEAP_TYPE_UPLOAD,D3D12_RESOURCE_STATE_GENERIC_READ,shader_record.data());
  auto ray_output = RuntimeBuffer(device,256,D3D12_HEAP_TYPE_DEFAULT,D3D12_RESOURCE_STATE_UNORDERED_ACCESS);
  auto ray_readback = RuntimeBuffer(device,256,D3D12_HEAP_TYPE_READBACK,D3D12_RESOURCE_STATE_COPY_DEST);
  command->SetComputeRootSignature(ray_root.Get());
  const D3D12_CONSTANT_BUFFER_VIEW_DESC ray_camera_cbv{camera_buffer->GetGPUVirtualAddress(), uint32_t(camera_buffer->GetDesc().Width)};
  const D3D12_CONSTANT_BUFFER_VIEW_DESC ray_extra_cbv{zero->GetGPUVirtualAddress(), uint32_t(zero->GetDesc().Width)};
  device->CreateConstantBufferView(&ray_camera_cbv, cpu(160));
  device->CreateConstantBufferView(&ray_extra_cbv, cpu(161));
  command->SetComputeRootDescriptorTable(0, gpu(160));
  command->SetComputeRootConstantBufferView(1,frame_buffer->GetGPUVirtualAddress());
  command->SetComputeRootDescriptorTable(2,gpu(0)); command->SetComputeRootDescriptorTable(3,gpu(128));
  command->SetComputeRootDescriptorTable(4,samplers->GetGPUDescriptorHandleForHeapStart());
  command->SetComputeRootConstantBufferView(5,sentinel_buffer->GetGPUVirtualAddress());
  command->SetComputeRoot32BitConstants(6,4,ray_words,0);
  command->SetComputeRootDescriptorTable(7,gpu(0)); command->SetComputeRootDescriptorTable(8,samplers->GetGPUDescriptorHandleForHeapStart());
  command->SetComputeRootUnorderedAccessView(9,ray_output->GetGPUVirtualAddress()); command->SetComputeRootDescriptorTable(10,gpu(0));
  command->SetPipelineState1(state_object.Get());
  D3D12_DISPATCH_RAYS_DESC dispatch{}; dispatch.RayGenerationShaderRecord = {shader_table->GetGPUVirtualAddress(),64}; dispatch.Width = dispatch.Height = dispatch.Depth = 1;
  command->DispatchRays(&dispatch);
  D3D12_RESOURCE_BARRIER ray_barrier{}; ray_barrier.Type = D3D12_RESOURCE_BARRIER_TYPE_TRANSITION;
  ray_barrier.Transition = {ray_output.Get(),D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES,D3D12_RESOURCE_STATE_UNORDERED_ACCESS,D3D12_RESOURCE_STATE_COPY_SOURCE}; command->ResourceBarrier(1,&ray_barrier);
  command->CopyResource(ray_readback.Get(),ray_output.Get());
  D3D12_PLACED_SUBRESOURCE_FOOTPRINT scene_footprint{}; uint64_t scene_bytes = 0;
  const auto scene_desc = targets[4]->GetDesc(); device->GetCopyableFootprints(&scene_desc,0,1,0,&scene_footprint,nullptr,nullptr,&scene_bytes);
  auto readback = RuntimeBuffer(device, scene_bytes * 2 + 256, D3D12_HEAP_TYPE_READBACK, D3D12_RESOURCE_STATE_COPY_DEST);
  auto copy_image = [&](uint32_t slot, uint64_t offset) {
    D3D12_RESOURCE_BARRIER barrier{}; barrier.Type = D3D12_RESOURCE_BARRIER_TYPE_TRANSITION; barrier.Transition = {targets[slot].Get(),D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES,D3D12_RESOURCE_STATE_RENDER_TARGET,D3D12_RESOURCE_STATE_COPY_SOURCE}; command->ResourceBarrier(1,&barrier);
    D3D12_TEXTURE_COPY_LOCATION source{targets[slot].Get(),D3D12_TEXTURE_COPY_TYPE_SUBRESOURCE_INDEX}, destination{readback.Get(),D3D12_TEXTURE_COPY_TYPE_PLACED_FOOTPRINT}; destination.PlacedFootprint = scene_footprint; destination.PlacedFootprint.Offset = offset;
    command->CopyTextureRegion(&destination,0,0,0,&source,nullptr); std::swap(barrier.Transition.StateBefore,barrier.Transition.StateAfter); command->ResourceBarrier(1,&barrier);
  };
  copy_image(4,0); copy_image(5,scene_bytes);
  Check(command->Close()); ID3D12CommandList* lists[] = {command.Get()}; queue->ExecuteCommandLists(1,lists);
  ComPtr<ID3D12Fence> fence; Check(device->CreateFence(0,D3D12_FENCE_FLAG_NONE,IID_PPV_ARGS(&fence))); Check(queue->Signal(fence.Get(),1));
  const HANDLE completed = CreateEvent(nullptr,FALSE,FALSE,nullptr); Check(fence->SetEventOnCompletion(1,completed));
  if (WaitForSingleObject(completed,60000) != WAIT_OBJECT_0) throw std::runtime_error("Cloud runtime GPU timeout"); CloseHandle(completed); Check(device->GetDeviceRemovedReason());
  void* mapped = nullptr; Check(readback->Map(0,nullptr,&mapped));
  void* before_card = nullptr; Check(pre_card->Map(0,nullptr,&before_card));
  for (uint32_t y = 0; y < height; ++y) for (uint32_t x = 0; x < width; ++x) {
    const auto* value = reinterpret_cast<const float*>(static_cast<const uint8_t*>(before_card)
        + y * pre_card_footprint.Footprint.RowPitch + x * 16);
    if (std::abs(value[0]-background[0]) > .005f || value[3] != background[3])
      throw std::runtime_error("Cloud composite ran before the native sun and cloud-card draws");
  }
  pre_card->Unmap(0,nullptr);
  void* atlas_pixels=nullptr;Check(atlas_readback->Map(0,nullptr,&atlas_pixels));
  const auto* atlas_center=reinterpret_cast<const float*>(static_cast<const uint8_t*>(atlas_pixels)
      +128u*atlas_footprint.Footprint.RowPitch+128u*16u);
  if(!std::isfinite(atlas_center[0])||std::abs(atlas_center[0]-.8f)<.03f)
    throw std::runtime_error("Actual addon did not replace the native six-face cloud atlas");
  atlas_readback->Unmap(0,nullptr);
  uint32_t changed = 0;
  for (uint32_t y = 0; y < height; ++y) for (uint32_t x = 0; x < width; ++x) {
    const auto* value = reinterpret_cast<const float*>(static_cast<const uint8_t*>(mapped) + y * scene_footprint.Footprint.RowPitch + x * 16);
    for (uint32_t channel = 0; channel < 4; ++channel) if (!std::isfinite(value[channel])) throw std::runtime_error("Cloud runtime produced non-finite radiance");
    if (value[3] != .75f) throw std::runtime_error("Cloud runtime changed native alpha");
    changed += std::abs(value[0] - background[0]) > .005f;
  }
  const auto* state_result = reinterpret_cast<const float*>(static_cast<const uint8_t*>(mapped) + scene_bytes);
  for (uint32_t index = 0; index < 4; ++index) if (std::abs(state_result[index] - (sentinel[index] + graphics_words[index] + clear_texture[index])) > 1.e-6f) throw std::runtime_error("Cloud graphics scope lost HDR CBV, root constants or descriptor table");
  readback->Unmap(0,nullptr);
  if (changed < 1000) throw std::runtime_error("Actual addon did not composite procedural clouds");
  void* ray_mapping = nullptr; Check(ray_readback->Map(0,nullptr,&ray_mapping));
  const auto* ray_values = static_cast<const uint32_t*>(ray_mapping);
  const auto* ray_floats = static_cast<const float*>(ray_mapping);
  if (ray_floats[3] != 1357 || ray_floats[0] < 1) throw std::runtime_error("Native DXR cloud shadow adapter did not publish a valid map");
  for (uint32_t index = 0; index < 4; ++index) {
    if (ray_values[4+index] != ray_words[index] || ray_values[8+index] != local_words[index]
        || ray_floats[12+index] != sentinel[index] || ray_floats[16+index] != clear_texture[index]
        || ray_floats[20+index] != camera[16][index]) throw std::runtime_error("Native DXR scope lost roots, local association, descriptor heaps or state object");
  }
  if (ray_floats[24] != 1.f || ray_floats[25] != 1.f || ray_floats[26] != 0.f || ray_floats[27] != 1.f)
    throw std::runtime_error("Native DXR dispatch did not get independent PBR controls");
  std::cout << "PT bounce cloud visibility/geometry/clock/ready=" << ray_floats[28] << "/"
            << ray_floats[29] << "/" << ray_floats[30] << "/" << ray_floats[31] << std::endl;
  if (!std::isfinite(ray_floats[28]) || ray_floats[28] < 0.f || ray_floats[28] >= .95f
      || ray_floats[29] != 0.f || ray_floats[30] != clock[0] || ray_floats[31] != 1.f)
    throw std::runtime_error("PT bounce lighting did not receive cloud attenuation and a valid native clock");
  ray_readback->Unmap(0,nullptr);
  // RTGI shades its probes before the next main sun draw. Its b0 is a
  // lighting-control buffer, so changing it must not change the weather clock.
  auto probe_native = Read(originals / "0xD2C88922.cs_6_6.cso");
  auto indirect_code = Read(probes / "cloud-indirect.cso");
  auto indirect_root = Root(device, true, 0, false, 1u << 9, true, true);
  D3D12_COMPUTE_PIPELINE_STATE_DESC indirect_desc{};
  indirect_desc.pRootSignature = indirect_root.Get();
  indirect_desc.CS = {probe_native.data(), probe_native.size()};
  ComPtr<ID3D12PipelineState> probe_lighting, indirect_check;
  Check(device->CreateComputePipelineState(&indirect_desc, IID_PPV_ARGS(&probe_lighting)));
  indirect_desc.CS = {indirect_code.data(), indirect_code.size()};
  Check(device->CreateComputePipelineState(&indirect_desc, IID_PPV_ARGS(&indirect_check)));
  auto deferred_native = Read(originals / "0x9A6F318E.cs_6_6.cso");
  auto controls_code = Read(probes / "lighting-controls.cso");
  ComPtr<ID3D12PipelineState> deferred_lighting, controls_check;
  indirect_desc.CS = {deferred_native.data(), deferred_native.size()};
  Check(device->CreateComputePipelineState(&indirect_desc, IID_PPV_ARGS(&deferred_lighting)));
  indirect_desc.CS = {controls_code.data(), controls_code.size()};
  Check(device->CreateComputePipelineState(&indirect_desc, IID_PPV_ARGS(&controls_check)));
  auto indirect_output = image(DXGI_FORMAT_R32G32B32A32_FLOAT, 1,
      D3D12_RESOURCE_FLAG_ALLOW_UNORDERED_ACCESS, D3D12_RESOURCE_STATE_UNORDERED_ACCESS, 1, 1);
  device->CreateUnorderedAccessView(indirect_output.Get(), nullptr, &texture_uav, cpu(132));
  D3D12_PLACED_SUBRESOURCE_FOOTPRINT indirect_footprint{};
  uint64_t indirect_bytes = 0;
  const auto indirect_image = indirect_output->GetDesc();
  device->GetCopyableFootprints(&indirect_image, 0, 1, 0, &indirect_footprint, nullptr, nullptr, &indirect_bytes);
  auto indirect_readback = RuntimeBuffer(device, indirect_bytes * 2, D3D12_HEAP_TYPE_READBACK, D3D12_RESOURCE_STATE_COPY_DEST);
  frame[286] = {.25f, -.125f, .5f, 0.f};
  Check(frame_buffer->Map(0, nullptr, &mapped));
  std::memcpy(mapped, frame.data(), sizeof(frame));
  frame_buffer->Unmap(0, nullptr);
  std::array<float, 64> probe_controls{};
  probe_controls[0] = 999.f;
  auto probe_control_buffer = RuntimeBuffer(device, sizeof(probe_controls),
      D3D12_HEAP_TYPE_UPLOAD, D3D12_RESOURCE_STATE_GENERIC_READ, probe_controls.data());
  for (uint32_t slot = 1; slot < 16; ++slot) {
    auto* resource = slot == 12 ? frame_buffer.Get() : slot == 13 ? light_buffer.Get() : zero.Get();
    const D3D12_CONSTANT_BUFFER_VIEW_DESC cbv{resource->GetGPUVirtualAddress(), uint32_t(resource->GetDesc().Width)};
    device->CreateConstantBufferView(&cbv, cpu(159 + slot));
  }
  auto probe_albedo_view = null_srv;
  probe_albedo_view.Format = gbuffer_formats[0];
  device->CreateShaderResourceView(targets[0].Get(), &probe_albedo_view, cpu(0));
  Check(allocator->Reset());
  Check(command->Reset(allocator.Get(), nullptr));
  command->SetDescriptorHeaps(2, native_heaps);
  command->SetComputeRootSignature(indirect_root.Get());
  command->SetComputeRootConstantBufferView(0, probe_control_buffer->GetGPUVirtualAddress());
  command->SetComputeRootDescriptorTable(1, gpu(160));
  command->SetComputeRootDescriptorTable(2, gpu(0));
  command->SetComputeRootDescriptorTable(3, gpu(128));
  command->SetComputeRootConstantBufferView(cloud_lighting_roots.at(reinterpret_cast<uint64_t>(indirect_root.Get())),
      zero->GetGPUVirtualAddress());
  command->SetPipelineState(probe_lighting.Get());
  command->Dispatch(0, 0, 0);
  command->SetPipelineState(indirect_check.Get());
  command->Dispatch(1, 1, 1);
  D3D12_RESOURCE_BARRIER indirect_barrier{};
  indirect_barrier.Type = D3D12_RESOURCE_BARRIER_TYPE_TRANSITION;
  indirect_barrier.Transition = {indirect_output.Get(), D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES,
      D3D12_RESOURCE_STATE_UNORDERED_ACCESS, D3D12_RESOURCE_STATE_COPY_SOURCE};
  command->ResourceBarrier(1, &indirect_barrier);
  D3D12_TEXTURE_COPY_LOCATION indirect_source{indirect_output.Get(), D3D12_TEXTURE_COPY_TYPE_SUBRESOURCE_INDEX};
  D3D12_TEXTURE_COPY_LOCATION indirect_destination{indirect_readback.Get(), D3D12_TEXTURE_COPY_TYPE_PLACED_FOOTPRINT};
  indirect_destination.PlacedFootprint = indirect_footprint;
  command->CopyTextureRegion(&indirect_destination, 0, 0, 0, &indirect_source, nullptr);
  std::swap(indirect_barrier.Transition.StateBefore, indirect_barrier.Transition.StateAfter);
  command->ResourceBarrier(1, &indirect_barrier);
  // Simulate an unavailable ray-material producer on this recording. Ordinary
  // PBR/contact controls must still bind, including when their previous root
  // value was explicitly cleared. Restore the opaque data before teardown.
  struct __declspec(uuid("50153788-2b89-4dfb-9d0d-d5939842111c")) ProducerRecording;
  GUID producer_recording = __uuidof(ProducerRecording);
  producer_recording.Data1 ^= 0x57484658u;
  uint64_t saved_producer = 0;
  cloud_host_command->get_private_data(reinterpret_cast<const uint8_t*>(&producer_recording), &saved_producer);
  if (!saved_producer) throw std::runtime_error("Missing production submission tracker in lighting regression");
  cloud_host_command->set_private_data(reinterpret_cast<const uint8_t*>(&producer_recording), 0);
  command->SetComputeRootConstantBufferView(cloud_lighting_roots.at(reinterpret_cast<uint64_t>(indirect_root.Get())),
      zero->GetGPUVirtualAddress());
  command->SetPipelineState(deferred_lighting.Get());
  command->Dispatch(0, 0, 0);
  cloud_host_command->set_private_data(reinterpret_cast<const uint8_t*>(&producer_recording), saved_producer);
  command->SetPipelineState(controls_check.Get());
  command->Dispatch(1, 1, 1);
  std::swap(indirect_barrier.Transition.StateBefore, indirect_barrier.Transition.StateAfter);
  command->ResourceBarrier(1, &indirect_barrier);
  indirect_destination.PlacedFootprint.Offset = indirect_bytes;
  command->CopyTextureRegion(&indirect_destination, 0, 0, 0, &indirect_source, nullptr);
  Check(command->Close());
  queue->ExecuteCommandLists(1, lists);
  Check(queue->Signal(fence.Get(), 2));
  const HANDLE indirect_completed = CreateEvent(nullptr, FALSE, FALSE, nullptr);
  Check(fence->SetEventOnCompletion(2, indirect_completed));
  if (WaitForSingleObject(indirect_completed, 60000) != WAIT_OBJECT_0)
    throw std::runtime_error("RTGI cloud source GPU timeout");
  CloseHandle(indirect_completed);
  Check(device->GetDeviceRemovedReason());
  Check(indirect_readback->Map(0, nullptr, &mapped));
  const auto* indirect_values = static_cast<const float*>(mapped);
  std::cout << "RTGI source cloud match/visibility/clock/lighting=" << indirect_values[0] << "/"
            << indirect_values[1] << "/" << indirect_values[2] << "/" << indirect_values[3] << std::endl;
  if (indirect_values[0] != 1.f || indirect_values[2] != clock[0]
      || indirect_values[3] != 1.f
      || !std::isfinite(indirect_values[1]) || indirect_values[1] < 0.f || indirect_values[1] > 1.f)
    throw std::runtime_error("RTGI cloud source used stale frame data or its lighting controls as the weather clock");
  const auto* surface_controls = reinterpret_cast<const float*>(static_cast<const uint8_t*>(mapped) + indirect_bytes);
  std::cout << "PBR/contact/soft/diameter controls=" << surface_controls[0] << "/" << surface_controls[1]
            << "/" << surface_controls[2] << "/" << surface_controls[3] << std::endl;
  if (surface_controls[0] != 1.f || surface_controls[1] != 1.f || surface_controls[2] != 1.f
      || std::abs(surface_controls[3] - 1.3f) > .000001f)
    throw std::runtime_error("PBR/contact controls depend on ray-material submission tracking");
  std::cout << "PASS: actual deferred PBR/contact controls without a ray-material producer tracker" << std::endl;
  indirect_readback->Unmap(0, nullptr);
  device->CreateShaderResourceView(depth.Get(), &depth_view, cpu(0));
  // Record stages out of order on the CPU, execute clock -> sun -> sky on
  // the GPU. Immutable clock pages identify the right source for each frame.
  constexpr uint32_t split_frames = 25;
  auto unknown_frame_buffer=RuntimeBuffer(device,sizeof(frame),D3D12_HEAP_TYPE_UPLOAD,D3D12_RESOURCE_STATE_GENERIC_READ,frame.data());
  std::array<ComPtr<ID3D12CommandAllocator>,split_frames*3> split_allocators;
  std::array<ComPtr<ID3D12GraphicsCommandList>,split_frames*3> split_commands;
  std::array<ComPtr<ID3D12Resource>,split_frames> split_clocks;
  std::array<ComPtr<ID3D12Resource>,split_frames> split_sky_clocks;
  auto split_readback = RuntimeBuffer(device,scene_bytes*split_frames,D3D12_HEAP_TYPE_READBACK,D3D12_RESOURCE_STATE_COPY_DEST);
  auto split_shadow_readback=RuntimeBuffer(device,indirect_bytes*split_frames,D3D12_HEAP_TYPE_READBACK,D3D12_RESOURCE_STATE_COPY_DEST);
  for (uint32_t tick = 0; tick < split_frames; ++tick) {
    clock[0] = 100.f+(tick+1)/60.f;
    split_clocks[tick] = RuntimeBuffer(device,sizeof(clock),D3D12_HEAP_TYPE_UPLOAD,D3D12_RESOURCE_STATE_GENERIC_READ,clock.data());
    // Signs can leave distinct GlobalCB allocations on the light and sky
    // draws. Their native time agrees; their GPU virtual addresses do not.
    if((tick&1u)!=0u)
      split_sky_clocks[tick]=RuntimeBuffer(device,sizeof(clock),D3D12_HEAP_TYPE_UPLOAD,D3D12_RESOURCE_STATE_GENERIC_READ,clock.data());
    for (uint32_t stage : {1u,2u,0u}) {
      const uint32_t index = tick*3+stage;
      Check(device->CreateCommandAllocator(D3D12_COMMAND_LIST_TYPE_DIRECT,IID_PPV_ARGS(&split_allocators[index])));
      Check(device->CreateCommandList(0,D3D12_COMMAND_LIST_TYPE_DIRECT,split_allocators[index].Get(),nullptr,IID_PPV_ARGS(&split_commands[index])));
      auto* list = split_commands[index].Get();
      list->SetDescriptorHeaps(2,native_heaps); list->SetGraphicsRootSignature(common.Get());
      for (uint32_t root = 0; root < 14; ++root) list->SetGraphicsRootConstantBufferView(root,zero->GetGPUVirtualAddress());
      list->SetGraphicsRootConstantBufferView(0,
          stage==1u ? sentinel_buffer->GetGPUVirtualAddress()
              : stage==2u &&split_sky_clocks[tick] ? split_sky_clocks[tick]->GetGPUVirtualAddress()
              : split_clocks[tick]->GetGPUVirtualAddress());
      list->SetGraphicsRootConstantBufferView(12,
          stage==2u &&tick+1u==split_frames ? unknown_frame_buffer->GetGPUVirtualAddress() : frame_buffer->GetGPUVirtualAddress());
      list->SetGraphicsRootConstantBufferView(13,light_buffer->GetGPUVirtualAddress());
      list->SetGraphicsRootDescriptorTable(14,gpu(0)); list->SetGraphicsRootDescriptorTable(15,gpu(128));
      list->RSSetViewports(1,&viewport); list->RSSetScissorRects(1,&scissor); list->IASetPrimitiveTopology(D3D_PRIMITIVE_TOPOLOGY_TRIANGLELIST);
      if (stage == 0) { list->OMSetRenderTargets(4,&first_target,TRUE,nullptr); list->SetPipelineState(gbuffer.Get()); }
      else { list->OMSetRenderTargets(1,&scene_target,FALSE,nullptr); list->SetPipelineState(stage == 1 ? sun.Get() : sky.Get()); }
      if (stage == 2) list->ClearRenderTargetView(scene_target,background,0,nullptr);
      list->DrawInstanced(0,1,0,0);
      if(stage==1u) {
        // Inspect terrain shadow time before the later sky pass can repair
        // it. GlobalCB on the light draw deliberately contains effect data.
        list->SetComputeRootSignature(indirect_root.Get());
        list->SetComputeRootConstantBufferView(0,probe_control_buffer->GetGPUVirtualAddress());
        list->SetComputeRootDescriptorTable(1,gpu(160));
        list->SetComputeRootDescriptorTable(2,gpu(0));
        list->SetComputeRootDescriptorTable(3,gpu(128));
        list->SetComputeRootConstantBufferView(cloud_lighting_roots.at(reinterpret_cast<uint64_t>(indirect_root.Get())),zero->GetGPUVirtualAddress());
        list->SetPipelineState(probe_lighting.Get());list->Dispatch(0,0,0);
        indirect_barrier.Transition.StateBefore=D3D12_RESOURCE_STATE_COPY_SOURCE;
        indirect_barrier.Transition.StateAfter=D3D12_RESOURCE_STATE_UNORDERED_ACCESS;
        list->ResourceBarrier(1,&indirect_barrier);
        list->SetPipelineState(indirect_check.Get());list->Dispatch(1,1,1);
        std::swap(indirect_barrier.Transition.StateBefore,indirect_barrier.Transition.StateAfter);
        list->ResourceBarrier(1,&indirect_barrier);
        D3D12_TEXTURE_COPY_LOCATION destination{split_shadow_readback.Get(),D3D12_TEXTURE_COPY_TYPE_PLACED_FOOTPRINT};
        destination.PlacedFootprint=indirect_footprint;destination.PlacedFootprint.Offset=tick*indirect_bytes;
        list->CopyTextureRegion(&destination,0,0,0,&indirect_source,nullptr);
      }
      if (stage == 2) {
        list->SetPipelineState(moon_disc.Get()); list->DrawInstanced(0,1,0,0);
        list->SetPipelineState(sun_disc.Get()); list->DrawInstanced(0,1,0,0);
        list->SetPipelineState(cloud_card.Get()); list->DrawInstanced(0,1,0,0);
        D3D12_RESOURCE_BARRIER barrier{}; barrier.Type = D3D12_RESOURCE_BARRIER_TYPE_TRANSITION;
        barrier.Transition = {targets[4].Get(),D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES,D3D12_RESOURCE_STATE_RENDER_TARGET,D3D12_RESOURCE_STATE_COPY_SOURCE}; list->ResourceBarrier(1,&barrier);
        D3D12_TEXTURE_COPY_LOCATION source{targets[4].Get(),D3D12_TEXTURE_COPY_TYPE_SUBRESOURCE_INDEX}, destination{split_readback.Get(),D3D12_TEXTURE_COPY_TYPE_PLACED_FOOTPRINT};
        destination.PlacedFootprint = scene_footprint; destination.PlacedFootprint.Offset = tick*scene_bytes;
        list->CopyTextureRegion(&destination,0,0,0,&source,nullptr);
        std::swap(barrier.Transition.StateBefore,barrier.Transition.StateAfter); list->ResourceBarrier(1,&barrier);
      }
      Check(list->Close());
    }
  }
  for (uint32_t tick = 0; tick < split_frames; ++tick) {
    ID3D12CommandList* stage_lists[] = {split_commands[tick*3].Get(),split_commands[tick*3+1].Get(),split_commands[tick*3+2].Get()};
    queue->ExecuteCommandLists(3,stage_lists);
  }
  Check(queue->Signal(fence.Get(),3)); const HANDLE split_completed = CreateEvent(nullptr,FALSE,FALSE,nullptr);
  Check(fence->SetEventOnCompletion(3,split_completed));
  if (WaitForSingleObject(split_completed,60000) != WAIT_OBJECT_0) throw std::runtime_error("Split cloud GPU timeout");
  CloseHandle(split_completed); Check(device->GetDeviceRemovedReason());
  void* shadow_mapping=nullptr;Check(split_shadow_readback->Map(0,nullptr,&shadow_mapping));
  for(uint32_t tick=0;tick<split_frames;++tick) {
    const auto* value=reinterpret_cast<const float*>(static_cast<const uint8_t*>(shadow_mapping)+tick*indirect_bytes);
    if(value[0]!=1.f ||value[2]!=100.f+(tick+1)/60.f)
      throw std::runtime_error("Early terrain shadow used the light/effect clock instead of the native scene clock at frame "+std::to_string(tick)+", time="+std::to_string(value[2]));
  }
  split_shadow_readback->Unmap(0,nullptr);
  void* split_mapping = nullptr; Check(split_readback->Map(0,nullptr,&split_mapping));
  for (uint32_t tick = 0; tick < split_frames; ++tick) {
    uint32_t cloud_pixels = 0;
    for (uint32_t y = 0; y < height; ++y) for (uint32_t x = 0; x < width; ++x) {
      const auto* value = reinterpret_cast<const float*>(static_cast<const uint8_t*>(split_mapping)+tick*scene_bytes+y*scene_footprint.Footprint.RowPitch+x*16);
      if (!std::isfinite(value[0]) || value[3] != background[3]) throw std::runtime_error("Split cloud radiance/alpha invalid");
      cloud_pixels += std::abs(value[0]-background[0]) > .005f;
    }
    if(tick+1u==split_frames) {
      if(cloud_pixels!=0u)throw std::runtime_error("A foreign b12 view borrowed another view's cloud admission");
    } else if (cloud_pixels < 1000) throw std::runtime_error("Split cloud frame was lost or matched the wrong clock page at frame "+std::to_string(tick));
  }
  split_readback->Unmap(0,nullptr);
  std::cout << "PASS 24 actual cloud frames, 75 delayed split recordings, distinct light/sky clock allocations, foreign-view rejection and GPU-ordered temporal publication" << std::endl;
  std::cout << "PASS five native DXR libraries, export/local-root association, real DispatchRays and compute/native state restoration" << std::endl;
  std::cout << "PASS actual-addon main cloud render, native weather/clock/light capture, foreground fog, HDR API-injected CBV/root constants/resource and sampler heaps. Changed=" << changed << std::endl;
}
